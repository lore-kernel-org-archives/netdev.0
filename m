From: bert hubert <ahu@ds9a.nl>
Subject: ipsec null encryption slower than AES / was Re: 2.6 IPSec Throughput puzzle
Date: Sat, 1 Jan 2005 22:03:47 +0100
Message-ID: <20050101210347.GA4713@outpost.ds9a.nl>
References: <EF311E6F9B0B0848A49ED20B06E9CB27031FDE7A@gluon.jnpr.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Networking Team <netdev@oss.sgi.com>, jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Shekhar Kshirsagar <shekhark@juniper.net>
Content-Disposition: inline
In-Reply-To: <EF311E6F9B0B0848A49ED20B06E9CB27031FDE7A@gluon.jnpr.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[added James Morris, resident crypto api guru, to the CC list] 

On Wed, Dec 29, 2004 at 03:50:34PM -0800, Shekhar Kshirsagar wrote:
> I played with oprofile for a while, and it seems that in case of null
> encryption, scatterwalk related code takes most of the cpu cycles.

Odd - the 'scatterlist' is what people were most proud of in the ipsec work
in 2.6. I recall that it was implemented as a natural way to represent the
encryption needs of ipsec. 

>From your numbers below it is clear all ipsec benchmarks have maxed out your
CPU, but aes/sha1 still has some hits in default_idle. Is this an SMP
system?

scatterwalk_done consists of crypto_kunmap, which in turn calls
kunmap_atomic (inline), which is defined as nothing sometimes and as a real
function otherwise which is not likely to be inlined, so should show up in
the profile if it were a large load.

The other part of scatterwalk_done is scatterwalk_page_done, which looks
like it could cause further (inlined) work.

But, in the end, I can't really help you further. All this scatterlist stuff
looks like something is really badly tuned for null-encryption and
well-tuned for encryption.

> Is there any place where I can find documentation about what exactly
> scatterwalk does?

http://www.certconf.org/presentations/2004/Tuesday/TS2.pdf - the concept is
called 'the scatterlist'.

http://lwn.net/Articles/14010/?format=printable is also nice.

Good luck!

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
