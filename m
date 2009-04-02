From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 3 Apr 2009 00:09:41 +0800
Message-ID: <20090402160941.GB2173@gondor.apana.org.au>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D487A6.407@redhat.com> <49D49C1F.6030306@novell.com> <200904022243.21088.rusty@rustcorp.com.au> <49D4B4A3.5070008@novell.com> <49D4B87D.2000202@redhat.com> <20090402145018.GA816@gondor.apana.org.au> <49D4D301.2090209@redhat.com> <20090402154041.GA1774@gondor.apana.org.au> <49D4E072.2060003@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory Haskins <ghaskins@novell.com>,
	Rusty Russell <rusty@rustcorp.com.au>, anthony@codemonkey.ws,
	andi@firstfloor.org, linux-kernel@vger.kernel.org, agraf@suse.de,
	pmullaney@novell.com, pmorreale@novell.com, netdev@vger.kernel.org,
	kvm@vger.kernel.org, Ingo Molnar <mingo@elte.hu>
To: Avi Kivity <avi@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764638AbZDBQ2m@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49D4E072.2060003@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 02, 2009 at 06:57:38PM +0300, Avi Kivity wrote:
>
> What if the guest sends N packets, then does some expensive computation  
> (say the guest scheduler switches from the benchmark process to  
> evolution).  So now we have the marker set at packet N, but the host  
> will not see it until the guest timeslice is up?

Well that's fine.  The guest will use up the remainder of its
timeslice.  After all we only have one core/hyperthread here so
this is no different than if the packets were held up higher up
in the guest kernel and the guest decided to do some computation.

Once its timeslice completes the backend can start plugging away
at the backlog.

Of course it would be better to put the backend on another core
that shares the cache or a hyperthread on the same core.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
