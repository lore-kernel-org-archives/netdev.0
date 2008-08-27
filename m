From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Question on netlink nested attributes
Date: Wed, 27 Aug 2008 22:57:56 +0200
Message-ID: <20080827205756.GW20815@postel.suug.ch>
References: <80769D7B14936844A23C0C43D9FBCF0F14DEB7D6@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@osdl.org" <shemminger@osdl.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:38853 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751214AbYH0U5i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 16:57:38 -0400
Content-Disposition: inline
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F14DEB7D6@orsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Duyck, Alexander H <alexander.h.duyck@intel.com> 2008-08-20 15:20
> I have a regression that was found in 2.6.26 in which the multiqueue option for the prio qdisc quit working after the commit referenced at http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.26.y.git;a=commit;h=b9a2f2e450b0f770bb4347ae8d48eb2dea701e24
> 
> The issue appears to be that the prio qdisc and the netem qdisc have two different ways that they are nesting the attributes they are passing to the qdisc layer but both use nla_parse_nested_compat.
> 
> The prio qdisc is laying out the message something like:
> hdr0(data+hdr1(hdr2(data)+hdr3(data)))

This format should use nla_parse_nested(data+sizeof(*data)), this is
the "regular" way.

> The netem qdisc is laying out the message something like:
> hdr0(data+hdr2(data)+hdr3(data))

This is the outdated way and thus "compat". Use
nla_parse_nested_compat().

> The question is which format is correct.  Just need to know so I can go about getting them both working the same way.

The format as used in prio qdisc is the preferred format. Nevertheless,
the netem format can't be changed, it is part of the ABI, therefore the
compat functions were added.
