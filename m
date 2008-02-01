From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] Disable TSO for non standard qdiscs
Date: Fri, 1 Feb 2008 01:28:15 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC32904737A40@orsmsx414.amr.corp.intel.com>
References: <47A2540D.8090003@gmail.com> <20080201074239.GA2897@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Patrick McHardy" <kaber@trash.net>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	<netdev@vger.kernel.org>
To: "Jarek Poplawski" <jarkao2@gmail.com>,
	"Andi Kleen" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:65356 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753270AbYBAJas convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 04:30:48 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080201074239.GA2897@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> ...But, on the other hand, in this case the realization seems to be
> wrong: probably still all locally created packets will be 
> treated the same - or I miss something?
> 
> Jarek P.

The TCP layer will generate TSO packets based on the kernel socket
features associated with the flow.  So if you have two devices, one
supporting TSO, the other not, then the flows associated with the
non-TSO device will not have their packets built for TSO.  This has no
bearing on the device supporting TSO, which its feature flags will
propogate into the kernel socket for that flow, and cause any TCP flows
to that device to be TSO packets.  So in a nutshell, disabling TSO is on
a per-device level, not a global switch.

-PJ Waskiewicz
