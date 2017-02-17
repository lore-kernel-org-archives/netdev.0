From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: RFC: unit tests for kernel GTP module
Date: Fri, 17 Feb 2017 16:02:59 +0100 (CET)
Message-ID: <1507789126.143172.1487343779235.JavaMail.zimbra@tpip.net>
References: <20170216220801.o3fajacj4sx3iere@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: osmocom-net-gprs <osmocom-net-gprs@lists.osmocom.org>,
        netdev <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@gnumonks.org>
To: laforge <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:47290 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933885AbdBQPDE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Feb 2017 10:03:04 -0500
In-Reply-To: <20170216220801.o3fajacj4sx3iere@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

----- On Feb 16, 2017, at 11:08 PM, laforge laforge@gnumonks.org wrote:

> Dear GTP-interested folks,
> 
> I would love to somehow get towards some degree of unit testing (or even
> "continuous integration") for teh kernel GTP code.
> 
> We currently have the original code in the kernel, we had some recent
> small fixes and now are getting more patches into place.  With
> relatively few active users out there (and probably none of them in
> production yet), it's particularly easy to introduce regressions while
> working on the code.  Also, having tested new code even against a
> test set with limited covrage could help to get more confidence in new
> patches and thus get them merged sooner.

We do run the current kernel code in production. The version I have
been push patches for will be deployed into prod soonish.

Automated testing is something we are also looking at. Currently, we
have cooperation going on with a vendor of a an RAN and EPC protocol
testing solution. The goal is to have a automated testing setup for
our GGSN/PDN-GW OpenSource project. That setup will also exercise the
kernel parts.
The test suite is proprietary, so we can only share the results but
not the test setup itself.

> Using tools like sgsnemu of OpenGGSN and the command line tools included
> in libgtpnl, it should be possibel to cook up some scripts for testing.
> Even the most basic set of tests would be an improvement over what we
> have now.  One could also think about pcap replay to test with
> hand-crafted or real-world packets from other GTP implementations.

We more or less removed static GTP tunnels. The tools in libgtpnl
only work when an application is keeping the GTP socket alive.

Andreas

> As much as I'd like to put something like this into place myself, I
> don't think I will be able to work much on this in the near future. The
> GTP module at this point is a pure hobby and contrary to some years ago
> while I started it, I don't have any contract work in the GTP area at
> this point, so other projects currently unfortunately get more
> attention.
> 
> So in case somebody among the GTP-interested parties (Travelping, OAI,
> ...) would want to do something in terms of testing, I'd be more than
> happy if somebody would step ahead.  Otherwise it's all just vapourware
> going to end up on my ever-growing TODO list :/
> 
> Also, if netdev folks have some ideas/pointers about possible
> frameworks/tools for this kind of testing [it must exist for at least
> some other kernel networking code?]: Please let me know.  I'd be
> interested to have a look if there's something that can be used as a
> basis (starting network namespaces, sending/transmitting packets, test
> case startup/teardown, ...)
> 
> My "old school" approach would have been to start one or multiple
> user-mode-linux kernels (those that are to be tested), and then have
> scripts that set up a gtp socket and gtp tunnels via the libgtp command
> line tools, and throw packets at that.   But I'm sure there must be
> quite powerful frameworks for that kind of testing in the 21st century?
> How do other tunneling implementations handle this?
> 
> Regards,
>	Harald
> --
> - Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
> ============================================================================
> "Privacy in residential applications is a desirable marketing option."
>                                                   (ETSI EN 300 175-7 Ch. A6)
