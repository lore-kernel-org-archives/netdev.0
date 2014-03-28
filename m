From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: For 3.14  [PATCH v3 net 1/3] xen-netback: remove pointless clause from if statement
Date: Fri, 28 Mar 2014 13:45:50 +0100
Message-ID: <1298007319.20140328134550@eikelenboom.it>
References: <1396006747-9113-1-git-send-email-paul.durrant@citrix.com> <1396006747-9113-2-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:41663 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbaC1Mp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 08:45:58 -0400
In-Reply-To: <1396006747-9113-2-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Friday, March 28, 2014, 12:39:05 PM, you wrote:

> This patch removes a test in start_new_rx_buffer() that checks whether
> a copy operation is less than MAX_BUFFER_OFFSET in length, since
> MAX_BUFFER_OFFSET is defined to be PAGE_SIZE and the only caller of
> start_new_rx_buffer() already limits copy operations to PAGE_SIZE or less.

> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Sander Eikelenboom <linux@eikelenboom.it>
> ---
>  drivers/net/xen-netback/netback.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 438d0c0..72314c7 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -192,8 +192,8 @@ static bool start_new_rx_buffer(int offset, unsigned long size, int head)
>          * into multiple copies tend to give large frags their
>          * own buffers as before.
>          */
> -       if ((offset + size > MAX_BUFFER_OFFSET) &&
> -           (size <= MAX_BUFFER_OFFSET) && offset && !head)
> +       BUG_ON(size > MAX_BUFFER_OFFSET);
> +       if ((offset + size > MAX_BUFFER_OFFSET) && offset && !head)
>                 return true;
>  
>         return false;

For the whole v3 series:

Reported-By: Sander Eikelenboom <linux@eikelenboom.it>
Tested-By: Sander Eikelenboom <linux@eikelenboom.it>

CC'ed Dave to get his attention since this is a last minute for 3.14.

--
Sander
