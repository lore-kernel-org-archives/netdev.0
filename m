From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] rds-tcp: Add module parameters to control
 sndbuf/rcvbuf size of RDS-TCP socket
Date: Fri, 11 Mar 2016 22:44:21 -0500
Message-ID: <20160312034421.GB26486@oracle.com>
References: <20160311182949.GG3383@oracle.com>
 <20160311110927.5c559421@xeon-e3>
 <20160312024341.GA26486@oracle.com>
 <CALx6S37+Zj-OmApDHzb2hq0jSLsbat4M9Xv6ASzB5VGP9HrQqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43014 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751917AbcCLDoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 22:44:34 -0500
Content-Disposition: inline
In-Reply-To: <CALx6S37+Zj-OmApDHzb2hq0jSLsbat4M9Xv6ASzB5VGP9HrQqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/11/16 19:21), Tom Herbert wrote:
> You could consider and alternate model where connection management
> (connect, listen, etc.) is performed in a userspace daemon and the
> attached to the kernel (pretty much like KCM does). This moves

You have to remember that, like it or not, RDS has some IB legacy 
compat requirements that cannot be shed easily.  The above suggestion
suddenly requiring an extra daemon per node in a cluster
involving 100's of nodes with very complex DB setup procedures and
rigid HA requirements (nodes in the cluster try to reconnect
on connection failure).  An extra daemon, with its own startup requirements
and additional latency, would be hard to justify for something
that can otherwise be done with module_param.

As such, the above suggestion is even non-trivial than the "ugly" code
I referred to in my previous email.

It is actually far simpler to just tell the cluster-setup scripts to just
refrain from an ifup of the relevant interfaces till all the config 
is set up.

Besides, the basic problem remains: for an arbitrary kernel module 
that has parameters that need to be customized before module init,
what are the options today?

--Sowmini
