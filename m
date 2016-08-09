From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: Regression introduced by "net: ipconfig: Support using "delayed"
 DHCP replies"
Date: Tue, 9 Aug 2016 12:18:19 +0200
Message-ID: <20160809101819.GL17139@pengutronix.de>
References: <CAMuHMdVjugL0y-C+vet=qbcER8rjuFKwFgrutRUAs=uOk0JZ1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:45538 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751337AbcHIKSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 06:18:22 -0400
Content-Disposition: inline
In-Reply-To: <CAMuHMdVjugL0y-C+vet=qbcER8rjuFKwFgrutRUAs=uOk0JZ1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Geert,

On Tue, Aug 09, 2016 at 12:02:44PM +0200, Geert Uytterhoeven wrote:
> Hi Uwe, David,
> 
> On current net-next, I see the following corruption during DHCP on
> r8a7791/koelsch, which uses the sh_eth driver:
> 
>      Sending DHCP requests ., OK
>      IP-Config: Got DHCP answer from 192.168.97.254, my address is 192.168.97.28
>      IP-Config: Complete:
> -         device=eth0, hwaddr=2e:09:0a:00:6d:85, ipaddr=192.168.97.28,
> mask=255.255.255.0, gw=192.168.97.254
> +         device=^M\xffffffc0\xffffffa0\xffffffe1,
> hwaddr=0e:9e:45:ac:dd:b4:3a:88:95:e1:50:af:0c:44:92:c0:6c:46:9f:02:34:1e:58:21:cd:c3:40:0c:ed:80:b1:74:10:0c:04:31:06:9f:04:01:04:93:5c:51:83:18:46:09,
> ipaddr=192.168.97.28, mask=255.255.255.0, gw=192.168.97.254

I fail to see the reason from looking at the patch. 

Is this reproducible? Can you please enable pr_debug output and provide
the corresponding output? What is your kernel command line? Are there >1
eth devices?

I will try to reproduce and fix later today.

> It may also crash in ip_auto_config() with e.g. "Unable to handle kernel NULL
> pointer dereference at virtual address 0000017d".
> 
> I've bisected this to commit 2647cffb2bc6fbed163d377390eb7ca552c7c1cb
> ('net: ipconfig: Support using "delayed" DHCP replies').
> Unfortunately just reverting that commit on current net-next is not a
> solution, as
> that may lead to DHCP failures:
> 
>     DHCP/BOOTP: Ignoring delayed packet
>     timed out!
>     [...]
>     IP-Config: Retrying forever (NFS root)...
> 
> Reverting also commit e068853409aa1720 ("net: ipconfig: drop inter-device
> timeout") fixes that, though.

That's not surprising. e068853409aa1720 was only possible because of
2647cffb2bc6fbed163d377390eb7ca552c7c1cb.

Best regards
Uwe

-- 
Pengutronix e.K.                           | Uwe Kleine-König            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
