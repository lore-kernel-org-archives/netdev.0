From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH v2 net-next] rds-tcp: Add sysctl tunables for
 sndbuf/rcvbuf on rds-tcp socket
Date: Tue, 15 Mar 2016 15:57:09 -0400
Message-ID: <20160315195709.GA16858@oracle.com>
References: <20160315151248.GJ11063@oracle.com>
 <CALx6S35FKYvnQ4O2N+3sJonj-gKODEMTwW6yeNcj1mWG9EOeow@mail.gmail.com>
 <20160315173438.GN11063@oracle.com>
 <CALx6S35f+DFTXCQgHPrMgdkAxEZKepWgZN2BowOp_Nt4nTpLgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	santosh.shilimkar@oracle.com,
	"David S. Miller" <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:20534 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965194AbcCOT5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 15:57:20 -0400
Content-Disposition: inline
In-Reply-To: <CALx6S35f+DFTXCQgHPrMgdkAxEZKepWgZN2BowOp_Nt4nTpLgg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/15/16 10:47), Tom Herbert wrote:
> Both sshd and nfsd and allow configurable listener port numbers. Any
> listener service will allow a configurable port number. An IANA port
> number is good as a default, but there are many reasons why people
> want or need to use a different port number. I don't see what makes
> RDS special in this regard.

Tom,

TCP is supposed to be the transparent infra for RDS-TCP.
If the server listens at something other than the well-known port,
the client kernel tcp socket has to know the value of the port to
connect to.  That means you also have to push down configuration
at each node, saying "client IP address X is to be connected at port Y"
etc. That is a lot of configuration information to manage in a cluster.
In addition to the volume of information that needs to be managed,
it also makes connectivity problems hard to trouble-shoot.

It has the danger of being a solution looking for a problem, because
we have not seen the use-case for this so far.

Thus to repeat what I said earlier,
 *if* some such need arises
and
 *if* there is absolutely no way to solve it with the existing infra,
there is nothing preventing a design extension to the daemon approach
in the future.

By itself, the sysctl support adds value and can co-exist with those
extensions.

--Sowmini
