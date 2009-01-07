From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 1/3] wimax: fix '#ifdef CONFIG_BUG' layout to avoid
 warning
Date: Wed, 7 Jan 2009 12:25:26 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0901071200080.27307@wrl-59.cs.helsinki.fi>
References: <cover.1231314782.git.inaky@linux.intel.com>
 <8baeb9679011f4f01a5f9709c725c4d829cb28bd.1231314782.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, wimax@linuxwimax.org,
	greg@kroah.com
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47659 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbZAGKZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 05:25:30 -0500
In-Reply-To: <8baeb9679011f4f01a5f9709c725c4d829cb28bd.1231314782.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 Jan 2009, Inaky Perez-Gonzalez wrote:

> Reported by Randy Dunlap:
> 
> > Also, this warning needs to be fixed:
> >
> > linux-next-20090106/net/wimax/id-table.c:133: warning: ISO C90
> > forbids mixed declarations and code
> 
> Move the return on #defined(CONFIG_BUG) below the variable
> declarations so it doesn't violate ISO C90.
> 
> On wimax_id_table_release() we want to do a debug check if CONFIG_BUG
> is enabled. However, we also want the debug code to be always compiled
> to ensure there is no bitrot.

I hope this kind of solution won't add some warnings? Besides, this seems 
rather strange reasoning as CONFIG_BUG is mostly enabled anyway?

> It will be optimized out by the compiler
> when CONFIG_BUG is disabled.
> 
> Added a note to the function header stating this.
> 
> Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
> ---
>  net/wimax/id-table.c |   10 ++++++----
>  1 files changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/net/wimax/id-table.c b/net/wimax/id-table.c
> index d3b8855..d6e0e8f 100644
> --- a/net/wimax/id-table.c
> +++ b/net/wimax/id-table.c
> @@ -123,15 +123,17 @@ void wimax_id_table_rm(struct wimax_dev *wimax_dev)
>  /*
>   * Release the gennetlink family id / mapping table
>   *
> - * On debug, verify that the table is empty upon removal.
> + * On debug, verify that the table is empty upon removal. We want the
> + * code always compiled, to ensure it doesn't bit rot. It will be
> + * compiled out if CONFIG_BUG is disabled.
>   */
>  void wimax_id_table_release(void)
>  {
> -#ifndef CONFIG_BUG
> -	return;
> -#endif
>  	struct wimax_dev *wimax_dev;
>  
> +#ifdef CONFIG_BUG

Did you perhaps mean ifndef here??? :-)

> +	return;
> +#endif
>  	spin_lock(&wimax_id_table_lock);
>  	list_for_each_entry(wimax_dev, &wimax_id_table, id_table_node) {
>  		printk(KERN_ERR "BUG: %s wimax_dev %p ifindex %d not cleared\n",
> 

-- 
 i.
