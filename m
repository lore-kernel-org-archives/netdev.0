From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: TCP sacked_out and fackets_out inconsistency (Was: Re: BUG: unable
 to handle kernel NULL pointer dereference at 000000000000002c)
Date: Wed, 08 Feb 2012 09:26:41 +0100
Message-ID: <4F3231C1.9040509@profihost.ag>
References: <20120201.162157.880976652659067010.davem@davemloft.net>  <4F2A87B0.6070900@profihost.ag>  <1328195055.2279.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20120202.143957.2251106530056768980.davem@davemloft.net>  <20120203004228.GA23429@kroah.com> <4F2B8348.3090305@profihost.ag>  <1328253972.2480.42.camel@edumazet-laptop> <4F2B963F.4020504@profihost.ag>  <1328267097.2157.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20120203155309.GB20638@kroah.com> <4F2F9784.7090203@profihost.ag> <1328519990.2220.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <alpine.DEB.2.00.1202061151580.2966@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Greg KH <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>, jwboyer@gmail.com,
	hch@infradead.org, Netdev <netdev@vger.kernel.org>,
	david@fromorbit.com, stable@vger.kernel.org,
	Greg KH <gregkh@suse.de>
To: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:41079 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755536Ab2BHI0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 03:26:42 -0500
In-Reply-To: <alpine.DEB.2.00.1202061151580.2966@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Am 06.02.2012 13:47, schrieb Ilpo J=E4rvinen:
>>> Any idea about that? Is it due to my custom patch being buggy or is=
 it
>>> anything you know which is missing in 3.0.X too?
>=20
> This warning is known to trigger every now and then...
>=20
>> Thats the tcp_fastretrans_alert()
>>
>> 	if (WARN_ON(!tp->sacked_out && tp->fackets_out))
>> 		tp->fackets_out =3D 0;
>>
>> I dont know if some recent patch addressed this issue.
>=20
> ...the recent fix from Neal to pick correct MSS might fix this but it=
=20
> is of course hard to confirm for sure (we'll see it indirectly eventu=
ally=20
> if there won't be anymore these rare splats). If one has infinite tim=
e it=20
> would be quite simple to see if changing mss setup triggers this and =
if=20
> the Neal's fix helped or not, however, I don't consider this particul=
ar=20
> inconsistency worth the effort.
>=20
> ...What I can say for sure is at least tp->fackets_out -=3D min(pkts_=
acked,=20
> tp->fackets_out); seems to fail when pkts_acked (u32) underflows due =
to=20
> the mss badness we used to have. So it could actually solve this for =
real.
>=20
> The effects of this counter inconsistency are not that devastating.=20
> Fackets_out mainly affect when recovery is triggered/which segments t=
o=20
> mark lost in the recovery itself. Two extremes I can think of: recove=
ry=20
> not triggered =3D> RTO triggers and everyone is happy except some res=
earcher=20
> who finds that odd and unwanted and needs to fix it :-); recovery in=20
> progress but works too much ahead, as if dupthresh (tp->reordering) w=
ould=20
> be slightly smaller (if in-order behavior in the network is assumed t=
his=20
> is still fully safe, dupthresh is there to help in cases of minor=20
> reordering).

What do you think about this? Can anybody give me the commit id?

Stefan
