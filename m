From: "Magnus Damm" <magnus.damm@gmail.com>
Subject: Re: [PATCH 3/3] ne-h8300: convert to net_device_ops
Date: Wed, 14 Jan 2009 15:37:24 +0900
Message-ID: <aec7e5c30901132237t6e810763i140b76ff8623dc63@mail.gmail.com>
References: <20081203201013.653215120@vyatta.com>
	 <20081203201028.533294548@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"Ben Dooks" <ben-linux@fluff.org>,
	"Paul Mundt" <lethal@linux-sh.org>, netdev <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:35823 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604AbZANGh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 01:37:27 -0500
Received: by bwz14 with SMTP id 14so1259882bwz.13
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2009 22:37:24 -0800 (PST)
In-Reply-To: <20081203201028.533294548@vyatta.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 4, 2008 at 5:10 AM, Stephen Hemminger <shemminger@vyatta.com> wrote:
> Another device using 8390 library that needs converting.
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
> --- a/drivers/net/Makefile      2008-12-03 12:04:17.000000000 -0800
> +++ b/drivers/net/Makefile      2008-12-03 12:07:25.000000000 -0800
> @@ -124,7 +124,7 @@ obj-$(CONFIG_NE3210) += ne3210.o 8390.o
>  obj-$(CONFIG_SB1250_MAC) += sb1250-mac.o
>  obj-$(CONFIG_B44) += b44.o
>  obj-$(CONFIG_FORCEDETH) += forcedeth.o
> -obj-$(CONFIG_NE_H8300) += ne-h8300.o
> +obj-$(CONFIG_NE_H8300) += ne-h8300.o 8390.o

Are you sure this will work? The ne-h8300 driver includes "lib8390.c"
in the main source with special configuration parameters such as
EI_SHIFT, but with this patch 8390.o contains another lib8390 instance
with a different configuration that gets tied into the net_device_ops.
I have no hardware and I may misunderstand the code, but please double
check.

I came across this when trying to fix another problem with ax88796.
Basically, another lib8390 patch (link below) forgets the case with
all drivers that include "lib8390.c" which in the ax88796 case results
in a missing start_xmit callback.

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=9a4a84294b0d60b8c287131478f743ba2bc68949

Paul, Ben, I have a fix for ax88796 that I'll post in a little while.

Cheers,

/ magnus
