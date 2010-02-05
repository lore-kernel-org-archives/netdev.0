From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Subject: Re: [PATCH] obsolete config in kernel source (HSO_AUTOPM)
Date: Fri, 05 Feb 2010 16:38:48 +0200
Message-ID: <4B6C2D78.20603@gmail.com>
References: <20100205133918.GA7077__48535.5327524759$1265377184$gmane$org@faui49.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Dumon <j.dumon@option.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Christoph Egger <siccegge@stud.informatik.uni-erlangen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from darkstar.wilibox.com ([195.14.175.138]:39468 "EHLO
	darkstar.wilibox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933193Ab0BEOix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 09:38:53 -0500
In-Reply-To: <20100205133918.GA7077__48535.5327524759$1265377184$gmane$org@faui49.informatik.uni-erlangen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/05/2010 03:39 PM, Christoph Egger wrote:
> Hi all!
>
> 	As part of the VAMOS[0] research project at the University of
> Erlangen we're checking referential integrity between kernel KConfig
> options and in-code Conditional blocks.
>
> 	This is just a one-liner commented out unconditionally (due to
> the config not existing) and being like this for virtually ever so I'm
> suggesting to remove it from the kernel tree.
>
> 	Please keep me informed of this patch getting confirmed /
> merged so we can keep track of it.
>
> Regards
>
> 	Christoph Egger
>
> [0] http://vamos1.informatik.uni-erlangen.de/
>
> ----
>  From 4d76c063b34cffd7b0f175e328f0878f262e6af2 Mon Sep 17 00:00:00 2001
> From: Christoph Egger<siccegge@stud.informatik.uni-erlangen.de>
> Date: Fri, 5 Feb 2010 13:46:21 +0100
> Subject: [PATCH] Remove unreferenced HSO_AUTOPM
>
> CONFIG_HSO_AUTOPM is set by KConfig / set in the Kernel source,
> makefiles and won't be ever set this way, therefor simply removing the
> protected code.
>
> Signed-off-by: Christoph Egger<siccegge@stud.informatik.uni-erlangen.de>
> ---
>   drivers/net/usb/hso.c |    3 ---
>   1 files changed, 0 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> index 6895f15..be0cc99 100644
> --- a/drivers/net/usb/hso.c
> +++ b/drivers/net/usb/hso.c
> @@ -1155,9 +1155,6 @@ static void _hso_serial_set_termios(struct tty_struct *tty,
>   static void hso_resubmit_rx_bulk_urb(struct hso_serial *serial, struct urb *urb)
>   {
>   	int result;
> -#ifdef CONFIG_HSO_AUTOPM
> -	usb_mark_last_busy(urb->dev);
> -#endif

Acctually this is bug. usb_mark_last_busy() should be called here.
Can you resend this patch by just removing #ifdef and #endif and
leaving usb_mark_last_busy()?

>   	/* We are done with this URB, resubmit it. Prep the USB to wait for
>   	 * another frame */
>   	usb_fill_bulk_urb(urb, serial->parent->usb,

