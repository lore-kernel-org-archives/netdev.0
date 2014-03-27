From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [PATCH net 1/3] xen-netback: remove pointless clause from if statement
Date: Thu, 27 Mar 2014 13:52:18 +0100
Message-ID: <885249016.20140327135218@eikelenboom.it>
References: <1395922988-37702-1-git-send-email-paul.durrant@citrix.com> <1395922988-37702-2-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:60036 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211AbaC0MwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 08:52:22 -0400
In-Reply-To: <1395922988-37702-2-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thursday, March 27, 2014, 1:23:06 PM, you wrote:

> This patch removes a test in start_new_rx_buffer() that checks whether
> a copy operation is less than MAX_BUFFER_OFFSET in length, since
> MAX_BUFFER_OFFSET is defined to be PAGE_SIZE and the only caller of
> start_new_rx_buffer() already limits copy operations to PAGE_SIZE or less.

> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Sander Eikelenboom <linux@eikelenboom.it>
> ---
>  drivers/net/xen-netback/netback.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)

> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 438d0c0..befc413 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -192,8 +192,7 @@ static bool start_new_rx_buffer(int offset, unsigned long size, int head)
>          * into multiple copies tend to give large frags their
>          * own buffers as before.
>          */
> -       if ((offset + size > MAX_BUFFER_OFFSET) &&
> -           (size <= MAX_BUFFER_OFFSET) && offset && !head)
> +       if ((offset + size > MAX_BUFFER_OFFSET) && offset && !head)
>                 return true;
>  
>         return false;


Will put this through the test now ..

--
Sander
