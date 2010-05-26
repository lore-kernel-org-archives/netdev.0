From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: ipv6: Add GSO support on forwarding path
Date: Wed, 26 May 2010 16:20:19 +0100
Message-ID: <20100526152019.GA11985@linux-mips.org>
References: <20100526102758.GA25914@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h5.dl5rb.org.uk ([81.2.74.5]:55539 "EHLO h5.dl5rb.org.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755346Ab0EZPUl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 May 2010 11:20:41 -0400
Content-Disposition: inline
In-Reply-To: <20100526102758.GA25914@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 26, 2010 at 08:27:58PM +1000, Herbert Xu wrote:

> ipv6: Add GSO support on forwarding path
> 
> Currently we disallow GSO packets on the IPv6 forward path.
> This patch fixes this.
> 
> Note that I discovered that our existing GSO MTU checks (e.g.,
> IPv4 forwarding) are buggy in that they skip the check altogether, 
> hen they really should be checking gso_size instead.
> 
> I have also been lazy here in that I haven't bothered to segment
> the GSO packet by hand before generating an ICMP message.  Someone
> should add that to be 100% correct.
> 
> Reported-by: Ralf Baechle <ralf@linux-mips.org>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I tested this on top of a 2.6.34 release kernel and asked the user
experiencing the problem to re-test and the problem still persists.

Unlike what I told you earlier on IRC my tester can trigger the issue
by going to any page on linux-ax25.org from any XP, Vista or Windows 7
client.

I've got three tcpdumps of the hang occuring on ftp.linux-ax25.org

  /pub/dl1bff.log
  /pub/dl1bff-2.log
  /pub/dl1bff-3.log

The first two were taken with a 2.6.32 Fedora 12 kernel; the 3rd with
a stock 2.6.34 kernel and your patch applied on top.  The issue exists
for quite a while; it has first been noticed with Fedora 11.

  Ralf
