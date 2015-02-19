From: Karl Beldan <karl.beldan@gmail.com>
Subject: Re: [PATCH 3.12 065/122] lib/checksum.c: fix carry in
 csum_tcpudp_nofold
Date: Fri, 20 Feb 2015 00:47:21 +0100
Message-ID: <20150219234721.GA22013@magnum.frso.rivierawaves.com>
References: <cover.1424099973.git.jslaby@suse.cz>
 <07707a797d6c3cd0bfe86f037d3d1eb329acbc86.1424099973.git.jslaby@suse.cz>
 <063D6719AE5E284EB5DD2968C1650D6D1CAE4D1E@AcuExch.aculab.com>
 <20150217195717.GA6779@magnum.frso.rivierawaves.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CAE56AE@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: 'Jiri Slaby' <jslaby@suse.cz>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Karl Beldan <karl.beldan@rivierawaves.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Mike Frysinger <vapier@gentoo.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAE56AE@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 18, 2015 at 09:40:23AM +0000, David Laight wrote:
> From: Karl Beldan 
> > On Tue, Feb 17, 2015 at 12:04:22PM +0000, David Laight wrote:
> > > > +static inline u32 from64to32(u64 x)
> > > > +{
> > > > +	/* add up 32-bit and 32-bit for 32+c bit */
> > > > +	x = (x & 0xffffffff) + (x >> 32);
> > > > +	/* add up carry.. */
> > > > +	x = (x & 0xffffffff) + (x >> 32);
> > > > +	return (u32)x;
> > > > +}
> > >
> > > As a matter of interest, does the compiler optimise away the
> > > second (x & 0xffffffff) ?
> > > The code could just be:
> > > 	x = (x & 0xffffffff) + (x >> 32);
> > > 	return x + (x >> 32);
> > >
> >
> > On my side, from what I've seen so far, your version results in better
> > assembly, esp. with clang, but my first version
> > http://article.gmane.org/gmane.linux.kernel/1875407:
> >         x += (x << 32) + (x >> 32);
> > 	return (__force __wsum)(x >> 32);
> > resulted in even better assembly, I just verified with gcc/clang,
> > x86_64/ARM and -O1,2,3.
> 
> The latter looks to have a shorter dependency chain as well.
> Although I'd definitely include a comment saying that it is equivalent
> to the two lines in the current patch.
> 
> Does either compiler manage to use a rotate for the two shifts?
> Using '(x << 32) | (x >> 32)' might convince it to do so.
> That would reduce it to three 'real' instructions and a register rename.
> 
gcc and clang rotate for tile (just checked gcc) and x86_64, not for arm
(and IMHO rightly so).
Both '|' and '+' yielded the same asm for those 3 archs.
 
Karl
