From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Thu, 16 Aug 2007 11:54:44 +0200
Message-ID: <46C41EE4.9090806@s5r6.in-berlin.de>
References: <18115.44462.622801.683446@cargo.ozlabs.ibm.com> <20070816020042.GA30650@gondor.apana.org.au> <18115.45316.702491.681906@cargo.ozlabs.ibm.com> <alpine.LFD.0.999.0708160800130.24380@enigma.security.iitk.ac.in> <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in> <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au> <46C40587.7050708@s5r6.in-berlin.de> <20070816081049.GA1431@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Paul Mackerras <paulus@samba.org>,
	Satyam Sharma <satyam@infradead.org>,
	Christoph Lameter <clameter@sgi.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Chris Snook <csnook@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764980AbXHPJzB@vger.kernel.org>
In-Reply-To: <20070816081049.GA1431@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Thu, Aug 16, 2007 at 10:06:31AM +0200, Stefan Richter wrote:
>> > 
>> > Do you (or anyone else for that matter) have an example of this?
>> 
>> The only code I somewhat know, the ieee1394 subsystem, was perhaps
>> authored and is currently maintained with the expectation that each
>> occurrence of atomic_read actually results in a load operation, i.e. is
>> not optimized away.  This means all atomic_t (bus generation, packet and
>> buffer refcounts, and some other state variables)* and likewise all
>> atomic bitops in that subsystem.
> 
> Can you find an actual atomic_read code snippet there that is
> broken without the volatile modifier?

What do I have to look for?  atomic_read after another read or write
access to the same variable, in the same function scope?  Or in the sum
of scopes of functions that could be merged by function inlining?

One example was discussed here earlier:  The for (;;) loop in
nodemgr_host_thread.  There an msleep_interruptible implicitly acted as
barrier (at the moment because it's in a different translation unit; if
it were the same, then because it hopefully has own barriers).  So that
happens to work, although such an implicit barrier is bad style:  Better
enforce the desired behaviour (== guaranteed load operation) *explicitly*.
-- 
Stefan Richter
-=====-=-=== =--- =----
http://arcgraph.de/sr/
