From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 21:25:36 +0400
Message-ID: <20060428172536.GA16916@2ka.mipt.ru>
References: <54AD0F12E08D1541B826BE97C98F99F143B0F3@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "David S. Miller" <davem@davemloft.net>, kelly@au1.ibm.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:58245 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1030462AbWD1R0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 13:26:40 -0400
To: Caitlin Bestler <caitlinb@broadcom.com>
Content-Disposition: inline
In-Reply-To: <54AD0F12E08D1541B826BE97C98F99F143B0F3@NT-SJCA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 28, 2006 at 10:02:10AM -0700, Caitlin Bestler (caitlinb@broadcom.com) wrote:
> If the app is really ready to use a modified interface we might as well
> just give them a QP/CQ interface. But I suppose "receive by pointer"
> interfaces don't really stretch the sockets interface all that badly.
> The key is that you have to decide how the buffer is released,
> is it the next call? Or a separate call? Does releasing buffer
> N+2 release buffers N and N+1? What you want to avoid 
> is having to keep a scoreboard of which buffers have been
> released.
> 
> But in context, header/data separation would allow in order
> packets to have the data be placed back to back, which 
> could allow a single recv to report the payload of multiple
> successive TCP segments. So the benefit of header/data
> separation remains the same, and I still say it's a optimization
> that should not be made a requirement. The benefits of vj_channels
> exist even without them. When the packet classifier runs on the
> host, header/data separation would not be free. I want to enable
> hardware offloads, not make the kernel bend over backwards
> to emulate how hardware would work. I'm just hoping that we
> can agree to let hardware do its work without being forced to
> work the same way the kernel does (i.e., running down a long
> list of arbitrary packet filter rules on a per packet basis).

I see your point, and respectfully disagree.
The more complex userspace interface we create the less users it will
have. It is completely unconvenient to read 100 bytes and receive only
80, since 20 were eaten by header. And what if we need only 20, but
packet contains 100, introduce per packet head pointer? 
For purpose of benchmarking it works perfectly -
read the whole packet, one can event touch that data to emulate real
work, but for the real world it becomes practically unusabl.

But what we are talking about right now is a research project, not
production system, so we can create any interface we like since the main
goal, IMHO, is searching for the bottlenecks in the current stack and
ways of it's removal even by introducing new complex interface.
I would definitely like to see how your approach works for some 
kind of real workloads and does it allow to
create faster and generally better systems.

-- 
	Evgeniy Polyakov
