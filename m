From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv3 0/6] tun zerocopy support
Date: Sun, 22 Jul 2012 01:05:34 +0300
Message-ID: <20120721220534.GA22912@redhat.com>
References: <cover.1342812067.git.mst@redhat.com>
 <20120720.174902.2055189237500355771.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, Ian Campbell <Ian.Campbell@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120720.174902.2055189237500355771.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 20, 2012 at 05:49:02PM -0700, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Fri, 20 Jul 2012 22:23:03 +0300
> 
> > Same as with macvtap, I get single-percentage wins in CPU utilization
> > on guest to external from this patchset, and a performance regression on
> > guest to host, so more work is needed until this feature can move out of
> > experimental status, but I think it's useful for some people already.
> > 
> > Pls review and consider for 3.6.
> 
> It doesn't improve performance in one case, and hurts performance in
> another.
> 
> You'll have to give me a more compelling argument than that.  You've
> just given me every reason not to include these patches in 3.6

OK let me clarify a bit, I think this wasn't explained well:
it's not true that this makes users suffer :)

This patch has no effect unless experimental zero copy mode in vhost-net
is enabled, and it is very clearly marked as experimental.

I agree a small win in CPU use is nothing to write home about,
I don't yet understand why the win is so small - macvtap has zero copy
supported for a while and it has exactly same issues.
I hope adding tun zerocopy support upstream will help us
make progress faster and find the bottleneck, so far not many people use
macvtap so zero copy mode there didn't make progress.

I do know why local performance regresses with zero copy enabled:
instead of plain copy to user we got get user pages and then memcpy.
We'll need some logic here to detect this and turn off zero copy.

The core patches will also be helpful for Ian's more ambitious work.

Overall I think it's a step in the right direction and it's easier to
work if core parts are upstream, but if you think we need to wait
until the gains are more significant, I understand that too.

-- 
MST
