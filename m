From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: HalfSipHash Acceptable Usage
Date: 21 Dec 2016 19:18:11 -0500
Message-ID: <20161222001811.7109.qmail@ns.sciencehorizons.net>
References: <20161221222702.h2vboms776zpgpi4@thunk.org>
Reply-To: kernel-hardening@lists.openwall.com
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
  djb@cr.yp.to, ebiggers3@gmail.com, eric.dumazet@gmail.com,
  hannes@stressinduktion.org, Jason@zx2c4.com,
  jeanphilippe.aumasson@gmail.com, kernel-hardening@lists.openwall.com,
  linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
  luto@amacapital.net, netdev@vger.kernel.org, tom@herbertland.com,
  torvalds@linux-foundation.org, vegard.nossum@gmail.com
To: linux@sciencehorizons.net, tytso@mit.edu
Return-path: <kernel-hardening-return-5756-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161221222702.h2vboms776zpgpi4@thunk.org>
List-Id: netdev.vger.kernel.org

Theodore Ts'o wrote:
> On Wed, Dec 21, 2016 at 01:37:51PM -0500, George Spelvin wrote:
>> SipHash annihilates the competition on 64-bit superscalar hardware.
>> SipHash dominates the field on 64-bit in-order hardware.
>> SipHash wins easily on 32-bit hardware *with enough registers*.
>> On register-starved 32-bit machines, it really struggles.

> And "with enough registers" includes ARM and MIPS, right?

Yes.  As a matter of fact, 32-bit ARM does particularly well
on 64-bit SipHash due to its shift+op instructions.

There is a noticeable performance drop, but nothing catastrophic.

The main thing I've been worried about is all the flow tracking
and NAT done by small home routers, and that's addressed by using
HalfSipHash for the hash tables.  They don't *initiate* a lot of
TCP sessions.

> So the only
> real problem is 32-bit x86, and you're right, at that point, only
> people who might care are people who are using a space-radiation
> hardened 386 --- and they're not likely to be doing high throughput
> TCP connections.  :-)

The only requirement on performance is "don't make DaveM angry." :-)

I was just trying to answer the question of why we *worried* about the
performance, not specifically argue that we *should* use HalfSipHash.
