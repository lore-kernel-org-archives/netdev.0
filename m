From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v1 0/9] forcedeth: stats & debug enhancements
Date: Wed, 9 Nov 2011 23:41:13 +0000
Message-ID: <1320882073.2781.20.camel@bwh-desktop>
References: <cover.1320875577.git.david.decotigny@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Decotigny <david.decotigny@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1320875577.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-11-09 at 14:09 -0800, David Decotigny wrote:
> These changes implement the ndo_get_stats64 API and add a few more
> stats and debugging features for forcedeth. They also ensure that
> stats updates are correct in SMP systems, 32 or 64-bits.
> 
> Regarding the "implement ndo_get_stats64() API" patch, I'm not sure
> I'm using the right way to protect the 64b stats. Ideally, I would
> like them to be non-blocking (u64_stats_sync.h), but as there are
> several sources for updates, I don't think I can do without locking or
> per-CPU stats.

The important thing is that the fast path remains fast, and I think
you've achieved that (due to patch 4/9).  The data path doesn't have to
acquire the stats lock and it only has to use atomic operations in some
error cases.

> Would per-CPU stats be better here (note: I expect the
> contention on netdev_priv(dev)->stats_lock to be _VERY_ low)?
[...]

Only queue-less software devices should maintain per-CPU stats.  For any
device with queues, servicing of each queue must already be serialised
and software stats can be maintained per-queue.  In the single-queue
case this means per-device.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
