From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next PATCH 01/15] net: Combine GENEVE and VXLAN port offload
 notifiers into single functions
Date: Wed, 15 Jun 2016 09:12:57 -0700
Message-ID: <CALx6S35NLSm=JKF=n01uB=ZQ3xe2GuANAkTUBepXjvRpyi07cg@mail.gmail.com>
References: <CAKgT0Uc8SZSsi9EULv0GVNO38OHhw__7_MDQ3PtDf-8y7+1Jgg@mail.gmail.com>
	<CALx6S359Q_qqj6Wc7K41hVfjzqHgLsHmH-91WTOS9tGw3=G5fA@mail.gmail.com>
	<CAKgT0Ue_-2KTMY6LsJjonTC7A16jB3hJZj+VU=4Fcp_9ZoNf+g@mail.gmail.com>
	<20160615.002205.499467944175786.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Alex Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Hannes Frederic Sowa <hannes@redhat.com>,
	Jesse Gross <jesse@kernel.org>, Jiri Benc <jbenc@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Dept-GELinuxNICDev@qlogic.com,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35317 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752493AbcFOQM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 12:12:58 -0400
Received: by mail-it0-f65.google.com with SMTP id e5so3965730ith.2
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 09:12:58 -0700 (PDT)
In-Reply-To: <20160615.002205.499467944175786.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 15, 2016 at 12:22 AM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Duyck <alexander.duyck@gmail.com>
> Date: Mon, 13 Jun 2016 19:50:02 -0700
>
>> I'm not going to speculate on what Dave's opinion on this is.  I'll
>> wait to hear it from him.
>>
>> My concern at this point is that we have several issues.  Specifically
>> we have VXLAN-GPE trying to pass itself off as VXLAN when it clearly
>> is not, and I know we are going to end up with somebody eventually
>> trying to push this feature into the kernel.  I know for a fact there
>> is hardware out there that already supports it.  I'm trying to get
>> ahead of this and define what the interface is supposed to look like
>> myself so that we don't end up with somebody unfamiliar with all this
>> trying to push it.  This way we can avoid having some hardware vendor
>> on a timeline trying to push it through quick as in the case of i40e,
>> or somebody trying to get around it by just hard coding it into their
>> driver like occurred with bnxt.
>>
>> While I appreciate the opinion, outright refusing to enable the
>> existing offloads is counterproductive.  There are customers out there
>> that already have this hardware.  There are driver writers out there
>> who are going to have to enable these features one way or another.  If
>> we want to be obstructionists then I am sure they can just work around
>> us and write up out-of-tree drivers and use something like module
>> parameters to enable offloads on a specific port.  Most of these
>> implementations only seem to support one port anyway.  I just thought
>> it might be better to have this figured out in the kernel so that we
>> didn't end up creating a bigger mess than needed with each vendor
>> going off and doing their own out-of-tree implementation.
>
> My plan is to try and properly balance the two side of this situation.
>
> Realistically, and Alex is right on this, we shoot ourselves in the
> foot by not supporting offloads that exist in hardware now even if
> they are not generic.
>
It was the interface that was rejected not any particular hardware
offload. We pointed out that n-tuple filtering is a much better
interface anyway allowing address binding and implementing offload for
new protocols without needed to change common header files. Besides,
if it's really just about VXLAN-GPE and that is the last of the
protocols in the three year HW pipeline then we can add another ndo
function specific for that.

Personally, I think the question of protocol specific offloads is moot
anyway. In the past six months the world since this issue came up the
world has moved forward. We have a lot better support for generic
offloads (Alex's patches on that), GRO for UDP is based on socket
lookup instead alternate lookup destination port, LCO has been
integrated, real support for ipxip6, extension headers being developed
that are going to be deployed, ILA allows virtualization without
encapsulation (no HW support needed), more IPv6 deployment in general,
MPLS/UDP is now an Internet standard, GRE/UDP will go to WGLC in IETF
soon, even more encapsulation protocols like IP/UDP have been
proposed, QUIC is being deployed and probably going to be a WG, first
TOU patches will soon be upstream, FD.io and DPDK are still making a
big fuss to bypass the kernel-- XDP is proving the kernel is not
problem, we now have first instances of truly programmable NICs using
BPF which is the path to truly generic offloads. This is really quite
an impressive list for sure! I don't see that protocol specific
offloads figure into much of this.

Tom

> So I would encourage Alex to keep working on his patch set and to
> keep working on the feedback he is given.
>
> Thanks.
