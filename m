From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [Security, resend] Instant crash with rtl8169 and large packets
Date: Mon, 08 Jun 2009 18:53:42 +0400
Message-ID: <4A2D25F6.9080300@msgid.tls.msk.ru>
References: <4A2D1147.8020101@msgid.tls.msk.ru> <4A2D1FE4.5030100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([81.13.33.159]:37150 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751731AbZFHOxm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jun 2009 10:53:42 -0400
In-Reply-To: <4A2D1FE4.5030100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you Eric for the reply.

Eric Dumazet wrote:
> Michael Tokarev a =E9crit :
[]
>> The situation is very simple: with an RTL8169 (probably
>> onboard) GigE card which, by default, is configured to
>> have MTU (maximal transmission unit) to be 1500 bytes,
>> it's *trivial* to instantly crash the machine by sending
>> it a *single* packet of size >1500 bytes (provided the
>> network switch can handle jumbo frames).
[]
>>  http://www.corpit.ru/mjt/r8169-mtu-oops.jpg

> I suppose you use a recent kernel ?

http://marc.info/?t=3D123462473200002 -- here's my first attempt,
at Feb this year.  It was 2.6.27 or so.  Right now I'm running
2.6.29[.4].  So I think yes, I use a recent kernel.

> Could you please try following patch ?
[]
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index e94316b..c08b97a 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -3468,7 +3468,7 @@ static int rtl8169_rx_interrupt(struct net_devi=
ce *dev,
> =20
>  		if (status & DescOwn)
>  			break;
> -		if (unlikely(status & RxRES)) {
> +		if (unlikely(status & (RxRES | RxRWT | RxRUNT | RxCRC | RxFOVF))) =
{
>  			if (netif_msg_rx_err(tp)) {
>  				printk(KERN_INFO
>  				       "%s: Rx ERROR. status =3D %08x\n",

Tried that one, got no printk (at least not a visible one) and exactly
the same OOPS as before.  Trivial test with

   ping -c1 -s3000 $my_ip_addr

(learned to add -c1 because the previous time my machine crashed severa=
l times
in a row till I figured out what's going on and unplugged the ethernet =
cord --
even if ping were running from an xterm executed from the machine to wh=
ich I
were pinging to! :)

Also got ext4fs corruption when rebooted (it's a staging area so nothin=
g important
is there but still.. "interesting").

Also tried 32bit kernel (were using 64bits -- exactly the same result).

I wish I had a serial cable or even a serial port on this machine.... B=
ut I guess
it'd not help anyway, because the machine locks hard.

Thanks!

/mjt
