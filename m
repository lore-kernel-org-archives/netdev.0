From: David Miller <davem@davemloft.net>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Thu, 27 Jul 2006 20:20:44 -0700 (PDT)
Message-ID: <20060727.202044.85689055.davem@davemloft.net>
References: <20060728014528.GB29313@innerghost.net>
	<20060727.192743.39159331.davem@davemloft.net>
	<20060728031322.GE29313@innerghost.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kazunori@miyazawa.org,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:36483
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751068AbWG1DVA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 23:21:00 -0400
To: hsantos@av.it.pt
In-Reply-To: <20060728031322.GE29313@innerghost.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hugo Santos <hsantos@av.it.pt>
Date: Fri, 28 Jul 2006 04:13:22 +0100

>    Certainly, control packets cause state transitions. TCP is a mixed
>  bag. I think the question here is whether we can afford a stack where
>  the data path is fully synchronous with the control path -- considering
>  the amount of "time" required by a state transition (and other burdens
>  you've identified). It might not pose a problem using the current
>  signalling, but as an example, if we consider SEcure Neighbor Discovery
>  (SEND, RFC 3971), validating a secure prefix to derive an address from,
>  involves checking certificate signatures (besides the
>  certificate-obtaining procedure); a process which may take some time.

We check AH4 hash signatures synchronously in the softirq packet
input path.  I know about async-crypto, but the point is that we
do this kind of heavy computation in the input path and it isn't
a big deal.

Now, if you're saying that, in response to a NDISC packet, we might
have to go out and obtain the certificate, before we can process
the NDISC packet.  This is a different issue.  Is that how this
secure NDISC works?  Or does the system obtain all the certificates
first, by some other means, and then either it can certify an NDISC
frame immediately or it can't?
