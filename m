From: Anton Blanchard <anton@samba.org>
Subject: Re: [patch] e1000 TSO parameter
Date: Tue, 29 Jul 2003 16:53:07 +1000
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030729065307.GC13227@krispykreme>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102229169@orsmsx402.jf.intel.com> <20030714214510.17e02a9f.davem@redhat.com> <16147.37268.946613.965075@napali.hpl.hp.com> <20030714223822.23b78f9b.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davidm@hpl.hp.com, davidm@napali.hpl.hp.com,
	scott.feldman@intel.com, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030714223822.23b78f9b.davem@redhat.com>
List-Id: netdev.vger.kernel.org


Hi,

> > So we get almost 15% of throughput drop.  This was with plain "netkit
> > fptd".  AFAIK, it does a simple read/write loop (not sendfile()).

We've been seeing rather variable results for TSO as well. With TSO off
netperf TCP_STREAM will hit line speed and stay there. With TSO on
some runs will hit line speed and others will be about 100Mbit/sec
slower.

> When we use TSO for non-sendfile() applications it really
> stresses memory allocations.  We do these 64K+ kmalloc()'s
> for each packet we construct.

Yep we definitely noticed much more higher allocations when watching
/proc/slab. Playing around with slab tuning didnt seem to help.

Anton
