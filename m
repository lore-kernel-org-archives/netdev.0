From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel panic when using bridge
Date: Tue, 12 Apr 2011 18:54:41 +0200
Message-ID: <1302627281.3233.70.camel@edumazet-laptop>
References: <4DA3F909.5020609@scotdoyle.com>
	 <1302608951.3233.33.camel@edumazet-laptop>
	 <1302613353.30934.22.camel@polaris.local>
	 <1302614145.3233.47.camel@edumazet-laptop>
	 <1302617968.30934.34.camel@polaris.local>
	 <1302619749.3233.56.camel@edumazet-laptop>
	 <1302621233.30934.44.camel@polaris.local>
	 <1302624851.3233.63.camel@edumazet-laptop>
	 <20110412092039.69f420f6@nehalam>
	 <1302626152.3233.66.camel@edumazet-laptop>
	 <20110412164557.GF2047@stratus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Jan =?ISO-8859-1?Q?L=FCbbe?= <jluebbe@debian.org>,
	Scot Doyle <lkml@scotdoyle.com>,
	Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	netdev@vger.kernel.org
To: Bandan Das <bandan.das@stratus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55206 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754684Ab1DLQyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 12:54:47 -0400
Received: by wwa36 with SMTP id 36so8141675wwa.1
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 09:54:46 -0700 (PDT)
In-Reply-To: <20110412164557.GF2047@stratus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 avril 2011 =C3=A0 12:45 -0400, Bandan Das a =C3=A9crit :
> On  0, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Le mardi 12 avril 2011 =C3=A0 09:20 -0700, Stephen Hemminger a =C3=A9=
crit :
> >=20
> > > I think the confusion is that IPCB(skb) is not the IP header but
> > > scratch space used during IP header processing. Before the saniti=
ze
> > > patch the CB was cleared.
> > >=20
> > > Acked-by: Stephen Hemminger <shemminger@vyatta.com>
> >=20
> > Should we clear it also in br_nf_dev_queue_xmit(), since we did thi=
s
> > prior to commit 462fb2af9788a8 ?
> >=20
> > Thanks !
> >=20
> Wouldn't that clear out any valid IP options if it were there ? I thi=
nk
> that was the whole point of adding br_parse_ip_options :
>=20
> /* BUG: Should really parse the IP options here. */
> memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
>=20
> =20
>=20

Oh yes, I missed br_nf_dev_queue_xmit() called br_parse_ip_options() an=
d
not ip_options_compile()

I'll submit an official patch, thanks !


