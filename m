From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Thu, 27 Jul 2006 21:07:38 -0700
Message-ID: <20060727210738.36f33436@localhost.localdomain>
References: <20060728014528.GB29313@innerghost.net>
	<20060727.192743.39159331.davem@davemloft.net>
	<20060728031322.GE29313@innerghost.net>
	<20060727.202044.85689055.davem@davemloft.net>
	<20060728033132.GF29313@innerghost.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	kazunori@miyazawa.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:62164 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751863AbWG1EIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 00:08:36 -0400
To: Hugo Santos <hsantos@av.it.pt>
In-Reply-To: <20060728033132.GF29313@innerghost.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Jul 2006 04:31:32 +0100
Hugo Santos <hsantos@av.it.pt> wrote:

> On Thu, Jul 27, 2006 at 08:20:44PM -0700, David Miller wrote:
> > 
> > Now, if you're saying that, in response to a NDISC packet, we might
> > have to go out and obtain the certificate, before we can process
> > the NDISC packet.  This is a different issue.  Is that how this
> > secure NDISC works?  Or does the system obtain all the certificates
> > first, by some other means, and then either it can certify an NDISC
> > frame immediately or it can't?
> 
>    It might happen that the host must ask the router for a Certification
>  Path by receiving a Router Advertisement. More specifically, RFC 3971
>  Section 6.4.6. 'Processing Rules for Hosts' states the following:
> 
>       The host SHOULD retrieve a certification path when a Router
>       Advertisement has been received with a public key that is not
>       available from a certificate in the hosts' cache, or when there is
>       no certification path to one of the host's trust anchors.  In
>       these situations, the host MAY send a Certification Path
>       Solicitation message to retrieve the path.  If there is no
>       response within CPS_RETRY seconds, the message should be retried.
>       The wait interval for each subsequent retransmission MUST
>       exponentially increase, doubling each time.  If there is no
>       response after CPS_RETRY_MAX seconds, the host abandons the
>       certification path retrieval process. (...)
> 
>    If no certification path is established, the RA must be treated as
>  unsecure. Secure prefixes are given preference over non-secure ones so
>  it might cause problems.
> 
>    Hugo

A couple of basic questions:
1. Can we just proceed assuming it is non-secure until a later time when
   the certificate path is established?
2. What if user process dies? or gets overwhelmed?
   One of the assumptions of the any well designed kernel is that the system should never
   hang because some user application died or waited for ever.

   

-- 
If one would give me six lines written by the hand of the most honest
man, I would find something in them to have him hanged. -- Cardinal Richlieu
