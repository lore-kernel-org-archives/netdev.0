From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: change the way e1000 is handling short VLAN frames
Date: Fri, 21 Sep 2007 10:05:37 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5203643506@orsmsx418.amr.corp.intel.com>
References: <1190379015.3551.57.camel@magi.nadr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"netdev mailing list" <netdev@vger.kernel.org>
To: "Emil Micek" <emil.micek@tkrjasek.cz>, <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:33126 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752501AbXIURFu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 13:05:50 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1190379015.3551.57.camel@magi.nadr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Emil Micek wrote:
> What is the right behaviour according to specification? In iee802.3,
> minFrameSize is 64bytes. I've never seen any document which'd say that
> VLAN frames should be 68 bytes minimum.

e1000 only hardware pads to 64 bytes, but if you use the vlan module and
turn off the hardware assistance of inserting tags, by unsetting
NETIF_F_HW_VLAN_* in netdev->features.
the software insertion sounds like it should work for you at the cost of
higher CPU.

>>> I'd like to change it so it first pads the frame to 64 B and
>>> appends the VLAN tag afterwards, so the resulting VLAN frame would
>>> be 68 bytes minimum.

at least for e1000 this isn't possible in the driver, while still doing
hardware vlan insertion.

Jesse
