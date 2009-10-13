From: jamal <hadi@cyberus.ca>
Subject: Re: kernel mode pppoe ppp if + ifb + mirred redirect, ethernet
	packets in ifb?!
Date: Tue, 13 Oct 2009 09:02:38 -0400
Message-ID: <1255438959.6305.13.camel@dogo.mojatatu.com>
References: <200910121143.39924.denys@visp.net.lb>
	 <200910130144.04910.denys@visp.net.lb>
	 <1255436477.6305.2.camel@dogo.mojatatu.com>
	 <200910131545.36946.denys@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Benjamin LaHaise <bcrl@kvack.org>
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:52544 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759642AbZJMNWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 09:22:45 -0400
Received: by qw-out-2122.google.com with SMTP id 9so868949qwb.37
        for <netdev@vger.kernel.org>; Tue, 13 Oct 2009 06:21:37 -0700 (PDT)
In-Reply-To: <200910131545.36946.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-10-13 at 15:45 +0300, Denys Fedoryschenko wrote:

> First problem, on restart and massive users login i am getting some weird 
> locking problem with modprobe,probably related to busybox/mdev.
> When interface come up, maybe it is problem of mdev, it is trying to do 
> modprobe with ip address as attribute. Probably they must not modprobe on 
> virtual interface. It is not easy to track who is reason of such call.
> 
> As result:
> [  174.564503] request_module: runaway loop modprobe 172.16.3.1
> [  174.564702] request_module: runaway loop modprobe 172.16.3.1
> [  174.801355] request_module: runaway loop modprobe 172.16.106.1
> [  174.801487] request_module: runaway loop modprobe 172.16.106.1
> [  175.011415] request_module: runaway loop modprobe 172.16.106.1
> load average (even it doesn't mean anything in terms of CPU load) jumps to 
> 72-80.
> 

Strange. But would probably make sense to modprobe the virtual interface
then assign ip address to it.

> Another bottleneck is u32 (i can optimize but) and some strange locks 
> appearing at top of perf, maybe same as logon case.

like you say u32 can be optimized

> And yes, pppd also appearing, but seems just registering new sysctls (for new 
> interface?) takes a lot of resources.
> 

back in the days (when i was involved in pppoe) pppd was a big problem
because it was not rentrant, so to solve the problem you exec a new
process for each user..
Ben Lahaise did a lot of work in this area and i am pretty sure decided
not to use pppd.

> I can post perf -a -f g if you are interested for "logging in" case and 
> regular operation.
> 

Sure - but i may not be much use to you..
I have CCed Ben.

> 
> Here is key part of shaper code:
> 

Ok - makes sense. I know some people using mark for ingress pseudo RPF.
And given instability of netfilter interface, I may just end up patching
skbedit.


> Well another way is just to use  as you suggest - egress on output 
> interface(s).

Sure; If it becomes an issue let me know.

cheers,
jamal


