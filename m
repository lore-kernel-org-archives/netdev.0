From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] rds-tcp: Add module parameters to control
 sndbuf/rcvbuf size of RDS-TCP socket
Date: Fri, 11 Mar 2016 23:39:52 -0500
Message-ID: <20160312043952.GC26486@oracle.com>
References: <20160311182949.GG3383@oracle.com>
 <20160311110927.5c559421@xeon-e3>
 <20160312024341.GA26486@oracle.com>
 <CALx6S37+Zj-OmApDHzb2hq0jSLsbat4M9Xv6ASzB5VGP9HrQqw@mail.gmail.com>
 <20160312034421.GB26486@oracle.com>
 <CALx6S37gHYMJdz3MzfjKwLHsw0Pmg0SxvQ036sg35AjRackARQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:16965 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbcCLEkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 23:40:01 -0500
Content-Disposition: inline
In-Reply-To: <CALx6S37gHYMJdz3MzfjKwLHsw0Pmg0SxvQ036sg35AjRackARQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/11/16 20:07), Tom Herbert wrote:

> You are describing your deployment of RDS, not kernel implementation.
> What I see is a very rigid implementation that would make it hard for
> many us to ever even consider deploying. The abilities of applications
> to tune TCP connections is well understood, very prevalent, and really
> fundamental in making TCP based datacenters at large scale.

sorry, historically, OS DDI/DKI's for kernel modules have always
had some way to set up startup parameters at module load time.  And 
clusters have been around for a while. 

So let's just focus on the technical question around module config here,
which involves more than TCP sockets, btw.

>  Any way, it was just an idea... ;-)

Thank you. 

Moving on,

> Maybe add one module parameter that indicates the module should just
> load but not start, configure whatever is needed via netlink, and then
> send one more netlink command to start operations.

Even that needs an extra daemon. 

Without getting into the vast number of questions that it raises (such
as every module with startup params now needs a uspace counterpart?
modprobe-r behavior, namespace behavior? Why netlink for every kernel
module? etc)..

One module parameter is as much a "distribution management"
problem as 10 of them, yes? I hope you see that I dont need that module
param and daemon baggage- I can just use  sysctl to set up all my params,
including one bit for module_can_start_now to achieve the same thing.

But it is still more than the handful of lines of code in my patch,
so it would be nice to understand what is the "distribution" issue.

Stepping back, how do we make sysctl fully namespace friendly? 

btw setting kernel socket keepalive params via sysctl is not a problem
to implement at all, if it ever shows up as a requirement for customers.

--Sowmini
