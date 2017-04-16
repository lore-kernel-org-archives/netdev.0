From: Guy Harris <guy@alum.mit.edu>
Subject: Re: TPACKET_V3 timeout bug?
Date: Sat, 15 Apr 2017 19:41:46 -0700
Message-ID: <251BA382-D82C-4931-A98F-A23AD88F9811@alum.mit.edu>
References: <20170415194042.GA5936@lunn.ch>
 <20170415224530.GA21010@oracle.com> <20170416021050.GA16418@lunn.ch>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        netdev <netdev@vger.kernel.org>,
        tcpdump-workers@lists.tcpdump.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c.mail.sonic.net ([64.142.111.80]:42510 "EHLO c.mail.sonic.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754504AbdDPCwy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 15 Apr 2017 22:52:54 -0400
In-Reply-To: <20170416021050.GA16418@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Apr 15, 2017, at 7:10 PM, Andrew Lunn <andrew@lunn.ch> wrote:

> Do you think this is a kernel problem, libpcap problem, or an
> application problem?

An application problem.  See my response on netdev; the timeout (which is provided by the kernel's capture mechanism, in most cases) is to make sure packets don't stay stuck in the kernel's packet buffer for an indefinite period of time, it's *not* to make sure a thread capturing packets doesn't stay blocked for an indefinite period of time.  Whether the timer goes off even if no packets have arrived is platform-dependent; code capturing packets should neither depend on it doing so or on it not doing so.
