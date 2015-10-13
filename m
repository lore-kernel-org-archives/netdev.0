From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Some ICMP-Reply messages don't arrive in User Space in recent
 Kernels
Date: Tue, 13 Oct 2015 15:18:12 +0200
Message-ID: <1444742292.1855606.408914113.79C7B013@webmail.messagingengine.com>
References: <CAEvAWuHSwA0=j_YDbowA56eCx10sJPm5KkveneSVhBQHNKY_zg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?UTF-8?Q?J=C3=B6rg=20Pommnitz?= <j.pommnitz@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:53735 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753103AbbJMNSN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 09:18:13 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 6A251207B5
	for <netdev@vger.kernel.org>; Tue, 13 Oct 2015 09:18:12 -0400 (EDT)
In-Reply-To: <CAEvAWuHSwA0=j_YDbowA56eCx10sJPm5KkveneSVhBQHNKY_zg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 13, 2015, at 08:47, J=C3=B6rg Pommnitz wrote:
> Hello all,
> I'm moving an application from 2.6.23 (yes, it's ancient; that's why
> we are moving) to 3.18LTS. The application monitors multiple network
> links to the same target with ping packets. The different links are
> selected either by their next hop router (Ethernet) or the network
> interface (Point-to-Point links, aka cellular data).
> To force different routes to the same target, the outgoing packets ar=
e
> tagged with different firewall marks. Then I'm using routing rules to
> select different routing tables with different routes for the same
> target.
> The outgoing path works perfectly fine in both, 2.6.23 and 3.18.
> However, the same is not true for the incoming ICMP replies. They are
> incoming; I see them with tcpdump. But some packets do not get
> delivered to user space in 3.18. I'm not 100% sure, but I think this
> happens if there is no "normal" route to the ping target, e.g. the
> source address of the ICMP replies. This looks like some kind of
> misguided ingress filtering that keeps packets out if a normal routin=
g
> lookup fails.
>=20
> Am I on the right track? If so, is there a way to disable this
> filtering? If not, what could cause this changed behaviour?

Did you disable rp_filter? Sounds like it, but 2.6.23 also had it
activated by default, so maybe you missed the option in sysctl.conf.

Bye,
Hannes
