From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [RFC PATCH 00/30] Kernel NET policy
Date: Tue, 19 Jul 2016 01:49:41 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F07712C19A4A@SHSMSX103.ccr.corp.intel.com>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
 <20160718151841.GA19066@breakpoint.cc>
 <20160718154512.GK5871@two.firstfloor.org>
 <7a03a353-4c1e-2bb4-2550-f84fc4cc79ac@stressinduktion.org>
 <20160718194357.GL5871@two.firstfloor.org>
 <1468878674.1778899.669950273.69750E32@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Florian Westphal <fw@strlen.de>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"keescook@chromium.org" <keescook@chromium.org>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"gorcunov@openvz.org" <gorcunov@openvz.org>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"aduyck@mirantis.com" <aduyck@mirantis.com>,
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:25842 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752244AbcGSBto convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 21:49:44 -0400
In-Reply-To: <1468878674.1778899.669950273.69750E32@webmail.messagingengine.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> 
> > Also of course it would be fundamentally less efficient than kernel
> > code doing that, just because of the additional context switches
> > needed.
> 
> Synchronizing or configuring any kind of queues already requires rtnl_mutex.
> I didn't test it but acquiring rtnl mutex in inet_recvmsg is unlikely to fly
> performance wise and

Yes, rtnl will bring some overheads. But the configuration is one time thing for
application or socket. It only happens on receiving first packet.
Unless the application/socket only transmit few packets, the overhead
could be ignored. If they only transmit few packets, why they care about
performance?

> might even be very dangerous under DoS attacks (like
> I see in 24/30).
> 
Patch 29/30 tries to prevent such case.

Thanks,
Kan
