From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATC] sctp: various fixes
Date: Mon, 21 Jul 2008 09:12:21 -0400
Message-ID: <48848B35.6050702@hp.com>
References: <12164416121552-git-send-email-vladislav.yasevich@hp.com>	<20080718.230833.22196996.davem@davemloft.net> <20080719.224047.228019059.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:12773 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbYGUNM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 09:12:26 -0400
In-Reply-To: <20080719.224047.228019059.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Fri, 18 Jul 2008 23:08:33 -0700 (PDT)
> 
>> From: Vlad Yasevich <vladislav.yasevich@hp.com>
>> Date: Sat, 19 Jul 2008 00:26:45 -0400
>>
>>> This is a bunch of SCTP fixes that have accumlated over the past week or
>>> so. 
>> All applied, thanks Vlad.
> 
> Vlad, I had to add the following fix to the tree in order
> to unbreak the build when CONFIG_HIGHMEM is enabled.
> 

ahh...  since tcp isn't a module, it didn't trigger that.

Thanks Dave.  I didn't think about turning highmem off..

-vlad

> highmem: Export totalhigh_pages.
> 
> Hash et al. sizing code in SCTP wants to make the
> calculation totalram_pages - totalhigh_pages, just
> like TCP.  But this requires an export for the
> CONFIG_HIGHMEM case to work.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/mm/highmem.c b/mm/highmem.c
> index 7da4a7b..e16e152 100644
> --- a/mm/highmem.c
> +++ b/mm/highmem.c
> @@ -40,6 +40,7 @@
>  #ifdef CONFIG_HIGHMEM
>  
>  unsigned long totalhigh_pages __read_mostly;
> +EXPORT_SYMBOL(totalhigh_pages);
>  
>  unsigned int nr_free_highpages (void)
>  {
> 

