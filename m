From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] ipip: add module alias for tunl0 tunnel device
Date: Tue, 30 Nov 2010 08:19:37 +0100
Message-ID: <1291101577.2725.41.camel@edumazet-laptop>
References: <20101129194746.724222156@vyatta.com>
	 <20101129194805.851988995@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64667 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753179Ab0K3HTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 02:19:44 -0500
Received: by wyb28 with SMTP id 28so5351754wyb.19
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 23:19:43 -0800 (PST)
In-Reply-To: <20101129194805.851988995@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 29 novembre 2010 =C3=A0 11:47 -0800, Stephen Hemminger a =C3=A9=
crit :
> pi=C3=A8ce jointe document texte brut (ipip-alias.patch)
> If ipip is built as a module the 'ip tunnel add' command would fail b=
ecause
> the ipip module was not being autoloaded.  Adding an alias for
> the tunl0 device name cause dev_load() to autoload it when needed.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> --- a/net/ipv4/ipip.c	2010-11-29 11:40:25.026277890 -0800
> +++ b/net/ipv4/ipip.c	2010-11-29 11:41:05.790681069 -0800
> @@ -913,3 +913,4 @@ static void __exit ipip_fini(void)
>  module_init(ipip_init);
>  module_exit(ipip_fini);
>  MODULE_LICENSE("GPL");
> +MODULE_ALIAS("tunl0");

I am not sure I understand you...

Here, I do have ipip built as a module, and I have no problem :

# lsmod|grep ipip
# ip tunnel add
cannot determine tunnel mode (ipip, gre or sit)
# lsmod|grep ipip
# ip tunnel add mode ipip
# lsmod|grep ipip
ipip                    7692  0=20
tunnel4                 2949  1 ipip
#=20

What am I missing ?


