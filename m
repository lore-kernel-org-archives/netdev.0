From: Bandan Das <bandan.das@stratus.com>
Subject: Re: Kernel panic when using bridge
Date: Tue, 12 Apr 2011 12:45:57 -0400
Message-ID: <20110412164557.GF2047@stratus.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Jan =?utf-8?B?TMO8YmJl?= <jluebbe@debian.org>,
	Scot Doyle <lkml@scotdoyle.com>,
	Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	netdev@vger.kernel.org, Bandan Das <bandan.das@stratus.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.stratus.com ([134.111.1.18]:35178 "EHLO
	mailhub5.stratus.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757651Ab1DLQqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 12:46:03 -0400
Content-Disposition: inline
In-Reply-To: <1302626152.3233.66.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On  0, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Le mardi 12 avril 2011 =C3=A0 09:20 -0700, Stephen Hemminger a =C3=A9=
crit :
>=20
> > I think the confusion is that IPCB(skb) is not the IP header but
> > scratch space used during IP header processing. Before the sanitize
> > patch the CB was cleared.
> >=20
> > Acked-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> Should we clear it also in br_nf_dev_queue_xmit(), since we did this
> prior to commit 462fb2af9788a8 ?
>=20
> Thanks !
>=20
Wouldn't that clear out any valid IP options if it were there ? I think
that was the whole point of adding br_parse_ip_options :

/* BUG: Should really parse the IP options here. */
memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));

=20

--=20
Bandan=20
