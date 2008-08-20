From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: Question on netlink nested attributes
Date: Wed, 20 Aug 2008 15:20:09 -0700
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F14DEB7D6@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shemminger@osdl.org" <shemminger@osdl.org>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17966 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752271AbYHTWUV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 18:20:21 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a regression that was found in 2.6.26 in which the multiqueue option for the prio qdisc quit working after the commit referenced at http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.26.y.git;a=commit;h=b9a2f2e450b0f770bb4347ae8d48eb2dea701e24

The issue appears to be that the prio qdisc and the netem qdisc have two different ways that they are nesting the attributes they are passing to the qdisc layer but both use nla_parse_nested_compat.

The prio qdisc is laying out the message something like:
hdr0(data+hdr1(hdr2(data)+hdr3(data)))

The netem qdisc is laying out the message something like:
hdr0(data+hdr2(data)+hdr3(data))

There is essentially an option header missing in the netem version of the nested netlink attributes message. The patch that went in seems to make things work without warnings for the netem approach but broke things for the prio approach.

The question is which format is correct.  Just need to know so I can go about getting them both working the same way.

Thanks,

Alex
