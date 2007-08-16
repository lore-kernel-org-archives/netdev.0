From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Thu, 16 Aug 2007 17:48:25 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0708161743500.13267@kivilampi-30.cs.helsinki.fi>
References: <20070816003948.GY9645@linux.vnet.ibm.com>
 <Pine.LNX.4.64.0708151740570.10497@schroedinger.engr.sgi.com>
 <18115.44462.622801.683446@cargo.ozlabs.ibm.com> <20070816020042.GA30650@gondor.apana.org.au>
 <18115.45316.702491.681906@cargo.ozlabs.ibm.com>
 <alpine.LFD.0.999.0708160800130.24380@enigma.security.iitk.ac.in>
 <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in>
 <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au>
 <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Paul Mackerras <paulus@samba.org>,
	Satyam Sharma <satyam@infradead.org>,
	Christoph Lameter <clameter@sgi.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Chris Snook <csnook@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, ak@suse.de,
	heiko.carstens@de.ibm.com, David Miller <davem@davemloft.net>,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38609 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751759AbXHPOs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 10:48:28 -0400
In-Reply-To: <20070816070907.GA964@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 16 Aug 2007, Herbert Xu wrote:

> We've been through that already.  If it's a busy-wait it
> should use cpu_relax. 

I looked around a bit by using some command lines and ended up wondering 
if these are equal to busy-wait case (and should be fixed) or not:

./drivers/telephony/ixj.c
6674:   while (atomic_read(&j->DSPWrite) > 0)
6675-           atomic_dec(&j->DSPWrite);

...besides that, there are couple of more similar cases in the same file 
(with braces)...


-- 
 i.
