From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Tue, 09 Apr 2013 07:31:04 -0700
Message-ID: <1365517864.3887.137.camel@edumazet-glaptop>
References: <3505145.vfXt1x4t0P@sifl> <28452040.xEi3pLPik0@sifl>
	 <1365516022.3887.131.camel@edumazet-glaptop> <2238729.HES6agzVX2@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Casey Schaufler <casey@schaufler-ca.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mvadkert@redhat.com, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org
To: Paul Moore <pmoore@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <2238729.HES6agzVX2@sifl>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-04-09 at 10:19 -0400, Paul Moore wrote:
> On Tuesday, April 09, 2013 07:00:22 AM Eric Dumazet wrote:
> > On Tue, 2013-04-09 at 09:19 -0400, Paul Moore wrote:
> > > As Casey already mentioned, if this isn't acceptable please help me
> > > understand why.
> > 
> > You see something which is not the reality. If you do such analysis,
> > better do it properly, because any change you are going to submit will
> > be doubly checked by people who really care.
> 
> I am attempting to do it properly, I simply made a mistake.  Ben also pointed 
> it out.  As you wrote yesterday, "Lets go forward".
> 
> After fixing the BITS_PER_LONG problem I looked at it again and it appears 
> that by simply replacing the "secmark" field with a blob we retain the size of 
> the sk_buff as well as the cacheline positions of all the fields, e.g. 
> dma_cookie no longer moves cachelines.  Thoughts?

If you take a look at recent history of changes on sk_buff, you can see
we added very recently fields for encapsulation support. These were
absolutely wanted for modern operations at datacenter level.

This effort might still need new room, so I prefer not filling sk_buff
right now.

Take a look at the cloned sk_buff. We need an extra atomic_t at the end,
so if make sk_buff bigger than 0xf8 bytes,  fclone_cache will use an
extra cache line as well. Not a big deal, but RPC workloads like netperf
-t TCP_RR will probably show a regression.

ls -l /sys/kernel/slab/skbuff_fclone_cache



