From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
Date: Mon, 1 Aug 2011 21:06:36 -0400
Message-ID: <20110802010635.GA16305@fieldses.org>
References: <1311921035.7845.10.camel@edumazet-laptop>
 <4E3258E1.6020000@fastmail.fm>
 <20110729103634.GA12050@infradead.org>
 <5933F48C-49D6-492D-AB7B-B76A3ADDB6C6@fastmail.fm>
 <1311941491.2843.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <F67B6E82-9FA8-464E-B3FB-DC0D4EC18BB0@fastmail.fm>
 <20110729164836.GL23194@fieldses.org>
 <20110729165345.GM23194@fieldses.org>
 <F562C6F4-3FC2-4952-A903-8E87E9EF2D9D@fastmail.fm>
 <20110730093025.716f3f50@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks <gnb-97jfqw80gc6171pxa8y+qA@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110730093025.716f3f50-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 30, 2011 at 09:30:25AM +1000, NeilBrown wrote:
> On Sat, 30 Jul 2011 06:34:44 +1000 Greg Banks <gnb-97jfqw80gc6171pxa8y+qA@public.gmane.org> wrote:
> > The "killall nfsd" semantics in those scripts are awful and lead to  
> > problems shutting down when there are lots of threads. It would  
> > probably be an improvement to provide a better shutdown mechanism and  
> > force distros to use it.
> 
> rpc.nfsd 0
> 
> will stop all nfsd threads.  Follow with
> 
>   exportfs -f
> 
> and you should be done.  I'm not 100% sure about the nfsv4 thread though -
> would need to check.
> 
> And yes - I would love it if distros could standardise on start/stop scripts
> so upstreams could maintain them sensibly.  This is my personal number 1
> reason for liking systemd - it pushes for this standardisation.

I can't remember if this is getting fixed in Fedora--probably not.  We
should fix it.

I'd also be fine with logging a deprecation message when someone signals
an nfsd thread.

> > Or, you could preserve the effective semantics by having a single  
> > "nfsd" thread whose purpose is to notice that it's being signalled and  
> > perform a clean shutdown (perhaps blocking the thread doing the kill()  
> > call until the shutdown has completed).
> 
> That's kinda neat.  It would be an ugly wart to have to keep around, but
> sometimes that the price we pay for "no regressions".

Yep; patch welcomed.

--b.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
