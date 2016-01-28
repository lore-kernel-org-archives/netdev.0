From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net 0/4] net: add rx_unhandled stat counter
Date: Thu, 28 Jan 2016 10:11:08 -0500
Message-ID: <20160128151108.GF59058@redhat.com>
References: <1453489882-57948-1-git-send-email-jarod@redhat.com>
 <1453926098-40181-1-git-send-email-jarod@redhat.com>
 <1453928987.20722.29.camel@edumazet-glaptop2.roam.corp.google.com>
 <20160128060215.GB59058@redhat.com>
 <20160128061808.GD59058@redhat.com>
 <1453986002.7627.20.camel@edumazet-glaptop2.roam.corp.google.com>
 <20160128143806.GE59058@redhat.com>
 <1453992162.7627.35.camel@edumazet-glaptop2.roam.corp.google.com>
 <1453992265.7627.37.camel@edumazet-glaptop2.roam.corp.google.com>
 <1453992410.7627.39.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tom Herbert <tom@herbertland.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1453992410.7627.39.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 28, 2016 at 06:46:50AM -0800, Eric Dumazet wrote:
> On Thu, 2016-01-28 at 06:44 -0800, Eric Dumazet wrote:
> > On Thu, 2016-01-28 at 06:42 -0800, Eric Dumazet wrote:
> > 
> > > 
> > > Sure, you also can set stats64->rx_unhandled to 0 here, just to be 100%
> > > safe.
> > 
> > And not add the memset(stats64, 0, sizeof(*stats64)), since we have the
> > guarantee to properly init whole stats64 structure.
> 
> Or a more tricky
> 
> memset((char *)stats64 + sizeof(struct net_device_stats),
>        0,
>        sizeof(*stats64) - sizeof(struct net_device_stats));

I think I like this best, since it won't require someone to notice they
have to add an explicit initialization if they add a new counter, as well
as saving us from memset'ing the entire struct, the majority of which
we'll initialize moments later. Just needs some documentation updates,
which I've done locally. Will rebuild, re-test, then hopefully get an
updated patchset out the door.

-- 
Jarod Wilson
jarod@redhat.com
