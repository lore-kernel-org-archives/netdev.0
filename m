From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC net-next 0/3] Proposal for VRF-lite
Date: Tue, 09 Jun 2015 14:43:14 +0200
Message-ID: <1433853794.2971689.290741201.37B469D8@webmail.messagingengine.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com>
 <20150609101550.GA10411@pox.localdomain> <5576DC4E.6060206@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Ahern <dsahern@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>, davem@davemloft.net,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	andy gospodarek <gospo@cumulusnetworks.com>,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:49529 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751955AbbFIMnP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 08:43:15 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id B427F21964
	for <netdev@vger.kernel.org>; Tue,  9 Jun 2015 08:43:14 -0400 (EDT)
In-Reply-To: <5576DC4E.6060206@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 9, 2015, at 14:30, Nicolas Dichtel wrote:
> Le 09/06/2015 12:15, Thomas Graf a =C3=A9crit :
> > On 06/08/15 at 11:35am, Shrijeet Mukherjee wrote:
> > [...]
> >> model with some performance paths that need optimization. (Specifi=
cally
> >> the output route selector that Roopa, Robert, Thomas and EricB are
> >> currently discussing on the MPLS thread)
> >
> > Thanks for posting these patches just in time. This explains how
> > you intent to deploy Roopa's patches in a scalable manner.
> >
> >> High Level points
> >>
> >> 1. Simple overlay driver (minimal changes to current stack)
> >>     * uses the existing fib tables and fib rules infrastructure
> >> 2. Modelled closely after the ipvlan driver
> >> 3. Uses current API and infrastructure.
> >>     * Applications can use SO_BINDTODEVICE or cmsg device indentif=
iers
> >>       to pick VRF (ping, traceroute just work)
> >
> > I like the aspect of reusing existing user interfaces. We might
> > need to introduce a more fine grained capability than CAP_NET_RAW
> > to give containers the privileges to bind to a VRF without
> > allowing them to inject raw frames.
> >
> > Given I understand this correctly: If my intent was to run a
> > process in multiple VRFs, then I would need to run that process
> > in the host network namespace which contains the VRF devices
> > which would also contain the physical devices. While I might want
> > to grant my process the ability to bind to VRFs, I may not want
> > to give it the privileges to bind to any device. So we could
> > consider introducing CAP_NET_VRF which would allow to bind to
> > VRF devices.
>=20
> If I understand correctly, all existing applications should also be
> modified
> if I want to run them into a VRF/MRF (see my previous email)?
>=20
> ssh, dhcp, httpd, etc should be runnable per MRF without modification=
s of
> their source code. So, it becomes a netns. What's about an IKE dameon=
?
>=20
> It makes sense to have both: netns and MRF ; each can have their own
> logics
> of VRF-like behavior depending on how a VRF is defined by the end use=
rs.

Agreed, the idea is to have a prctl in the end which gets inherited by
fork. current->rt_table_id or some kind of vrf specifier in task_struct
would make that possible then.

A helper tool like ip route exec table 100 /bin/bash would then start a
session bound to a specific routing instance.

Bye,
Hannes
