From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] ipip: add module alias for tunl0 tunnel device
Date: Tue, 30 Nov 2010 09:21:09 +0100
Message-ID: <1291105269.2725.52.camel@edumazet-laptop>
References: <20101129194746.724222156@vyatta.com>
	 <20101129194805.851988995@vyatta.com>
	 <1291101577.2725.41.camel@edumazet-laptop>
	 <AANLkTi=DFN=r5XLYEwb3RYOyTF+u0uTEUa3wX5i2ijJZ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39402 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754108Ab0K3IVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 03:21:15 -0500
Received: by wwa36 with SMTP id 36so5768546wwa.1
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 00:21:13 -0800 (PST)
In-Reply-To: <AANLkTi=DFN=r5XLYEwb3RYOyTF+u0uTEUa3wX5i2ijJZ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 novembre 2010 =C3=A0 15:55 +0800, Changli Gao a =C3=A9crit =
:
> On Tue, Nov 30, 2010 at 3:19 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le lundi 29 novembre 2010 =C3=A0 11:47 -0800, Stephen Hemminger a =C3=
=A9crit :
> >> pi=C3=A8ce jointe document texte brut (ipip-alias.patch)
> >> If ipip is built as a module the 'ip tunnel add' command would fai=
l because
> >> the ipip module was not being autoloaded.  Adding an alias for
> >> the tunl0 device name cause dev_load() to autoload it when needed.
> >>
> >> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >>
> >> --- a/net/ipv4/ipip.c 2010-11-29 11:40:25.026277890 -0800
> >> +++ b/net/ipv4/ipip.c 2010-11-29 11:41:05.790681069 -0800
> >> @@ -913,3 +913,4 @@ static void __exit ipip_fini(void)
> >>  module_init(ipip_init);
> >>  module_exit(ipip_fini);
> >>  MODULE_LICENSE("GPL");
> >> +MODULE_ALIAS("tunl0");
> >
> > I am not sure I understand you...
> >
> > Here, I do have ipip built as a module, and I have no problem :
> >
> > # lsmod|grep ipip
> > # ip tunnel add
> > cannot determine tunnel mode (ipip, gre or sit)
> > # lsmod|grep ipip
> > # ip tunnel add mode ipip
> > # lsmod|grep ipip
> > ipip                    7692  0
> > tunnel4                 2949  1 ipip
> > #
> >
> > What am I missing ?
> >
> >
>=20
> localhost linux # lsmod
> Module                  Size  Used by
> ipv6                  309359  12
> localhost linux # ip -V
> ip utility, iproute2-ss091226
> localhost linux # ip tunnel add mode gre
> ioctl: No such device
> localhost linux # ip tunnel add mode ipip
> ioctl: No such device
> localhost linux # modprobe ip_gre
> localhost linux # modprobe ipip
> localhost linux # ip tunnel add mode ipip
> localhost linux # ip tunnel add mode gre
> localhost linux # lsmod
> Module                  Size  Used by
> ipip                    8128  0
> tunnel4                 2683  1 ipip
> ip_gre                 15055  0
> gre                     1967  1 ip_gre
> ipv6                  309359  13 ip_gre
>=20
>=20

Hmm. I still dont get it, ipv6 as a module ?

Works well here.

# lsmod
Module                  Size  Used by
bonding                89194  0=20
ipv6                  232889  29 bonding
# ip tunnel add mode ipip
# lsmod
Module                  Size  Used by
ipip                    6221  0=20
bonding                89194  0=20
ipv6                  232889  29 bonding
# ip -V
ip utility, iproute2-ss100823
#=20


