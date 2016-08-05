From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [RFC V2 PATCH 00/25] Kernel NET policy
Date: Fri, 5 Aug 2016 13:44:25 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F07712C2375A@SHSMSX103.ccr.corp.intel.com>
References: <1420076354-4861-1-git-send-email-kan.liang@intel.com>
 <20160804170332.4304a907@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
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
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"decot@googlers.com" <decot@googlers.com>,
	"fw@strlen.de"
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:5496 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161167AbcHENo3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2016 09:44:29 -0400
In-Reply-To: <20160804170332.4304a907@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> 
> >  5. Why disable IRQ balance?
> >     A: Disabling IRQ balance is a common way (recommend way for some
> devices) to
> >        tune network performance.
> 
> I appreciate that network tuning is hard, most people get it wrong, and
> nobody agrees on the right answer.
> 
> So rather than fixing existing tools or writing new userspace tools to do
> network tuning, you want to hard code one policy manager in kernel with a
> /proc interface.

Current interaction is by /proc.  But it's not hard to have command line interface
to facilitate the user later. 
 
> Why not make a good userspace tool (like powertop).

AFAIK, Powertop mainly shows statistics and does global settings.
NET policy is more complex than powertop. It can do per process or per socket
setting. So it needs to coordinate requests from multiple users and dynamically
assign resource to users at run time. Considering the efficiency and complexity,
a kernel subsystem is more suitable, isn't it?

> There are also several
> IRQ balancing programs, but since irqbalance was championed by one
> vendor others seem to follow like sheep.

Based on my test, disabling IRQ balancing helps a lot for i40e performance.
So in my implementation, I made it a mandatory setting.
But NET policy intends to provide a generic infrastructure. If there are vendors
who want IRQ balancing, I think I can provide an option for the device driver.
Let the device driver decide if disabling IRQ balancing.

Thanks,
Kan

> 
> I agree that this a real concern but the implementation of this leaves much to
> be desired and discussed. Why can't this be done outside of the kernel.
