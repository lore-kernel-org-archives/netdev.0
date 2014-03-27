From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net 1/3] xen-netback: remove pointless clause from if
 statement
Date: Thu, 27 Mar 2014 12:24:23 +0000
Message-ID: <1395923063.22909.103.camel@kazak.uk.xensource.com>
References: <1395922988-37702-1-git-send-email-paul.durrant@citrix.com>
	 <1395922988-37702-2-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Sander Eikelenboom <linux@eikelenboom.it>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:16722 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754041AbaC0MYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 08:24:25 -0400
In-Reply-To: <1395922988-37702-2-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-27 at 12:23 +0000, Paul Durrant wrote:
> This patch removes a test in start_new_rx_buffer() that checks whether
> a copy operation is less than MAX_BUFFER_OFFSET in length, since
> MAX_BUFFER_OFFSET is defined to be PAGE_SIZE and the only caller of
> start_new_rx_buffer() already limits copy operations to PAGE_SIZE or less.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>

Acked-by: Ian Campbell <ian.campbell@citrix.com>

Although it would have been nice to consider a BUG_ON or ASSERT.

> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Sander Eikelenboom <linux@eikelenboom.it>
> ---
>  drivers/net/xen-netback/netback.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 438d0c0..befc413 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -192,8 +192,7 @@ static bool start_new_rx_buffer(int offset, unsigned long size, int head)
>  	 * into multiple copies tend to give large frags their
>  	 * own buffers as before.
>  	 */
> -	if ((offset + size > MAX_BUFFER_OFFSET) &&
> -	    (size <= MAX_BUFFER_OFFSET) && offset && !head)
> +	if ((offset + size > MAX_BUFFER_OFFSET) && offset && !head)
>  		return true;
>  
>  	return false;
