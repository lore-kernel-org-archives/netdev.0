From: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Subject: Re: [PATCH 0/6] fs: Scalability of sockets/pipes
 allocation/deallocation on SMP
Date: Fri, 28 Nov 2008 19:47:56 +0100
Message-ID: <1227898076.7392.16.camel@twins>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com>
	 <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com>
	 <20081121.010508.40225532.davem@davemloft.net>
	 <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com>
	 <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com>
	 <20081121153453.GA23713@elte.hu> <492DDB6A.8090806@cosmosbay.com>
	 <20081128180318.GL10487@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081128180318.GL10487-X9Un+BFzKDI@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2008-11-28 at 19:03 +0100, Ingo Molnar wrote:
> * Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org> wrote:
> 
> > Hi all
> >
> > Short summary : Nice speedups for allocation/deallocation of sockets/pipes
> > (From 27.5 seconds to 1.6 second)
> 
> Wow, that's incredibly impressive! :-)

Yeah, we got a similar speedup on -rt by pushing those super-block files
list into per-cpu lists and doing crazy locking on them.

Of course avoiding them all together, like done here is a nicer option
but is sadly not a possibility for regular files (until hch gets around
to removing the need for the list).
