From: Eduardo Valentin via Bridge <bridge@lists.linux-foundation.org>
Subject: Re: [PATCH 1/1] bridge: mdb: fix leak on complete_info ptr
 on fail path
Date: Wed, 12 Jul 2017 14:02:53 -0700
Message-ID: <20170712210253.GA26755@u40b0340c692b58f6553c.ant.amazon.com>
References: <1499810112-11790-1-git-send-email-eduval@amazon.com>
	<20170711.200233.1157747601793057593.davem@davemloft.net>
Reply-To: Eduardo Valentin <eduval@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20170711.200233.1157747601793057593.davem@davemloft.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 11, 2017 at 08:02:33PM -0700, David Miller wrote:
> From: Eduardo Valentin <eduval@amazon.com>
> Date: Tue, 11 Jul 2017 14:55:12 -0700
> 
> > We currently get the following kmemleak report:
> > unreferenced object 0xffff8800039d9820 (size 32):
> >   comm "softirq", pid 0, jiffies 4295212383 (age 792.416s)
> >   hex dump (first 32 bytes):
> >     00 0c e0 03 00 88 ff ff ff 02 00 00 00 00 00 00  ................
> >     00 00 00 01 ff 11 00 02 86 dd 00 00 ff ff ff ff  ................
> >   backtrace:
> >     [<ffffffff8152b4aa>] kmemleak_alloc+0x4a/0xa0
> >     [<ffffffff811d8ec8>] kmem_cache_alloc_trace+0xb8/0x1c0
> >     [<ffffffffa0389683>] __br_mdb_notify+0x2a3/0x300 [bridge]
> >     [<ffffffffa038a0ce>] br_mdb_notify+0x6e/0x70 [bridge]
> >     [<ffffffffa0386479>] br_multicast_add_group+0x109/0x150 [bridge]
> >     [<ffffffffa0386518>] br_ip6_multicast_add_group+0x58/0x60 [bridge]
> >     [<ffffffffa0387fb5>] br_multicast_rcv+0x1d5/0xdb0 [bridge]
> >     [<ffffffffa037d7cf>] br_handle_frame_finish+0xcf/0x510 [bridge]
> >     [<ffffffffa03a236b>] br_nf_hook_thresh.part.27+0xb/0x10 [br_netfilter]
> >     [<ffffffffa03a3738>] br_nf_hook_thresh+0x48/0xb0 [br_netfilter]
> >     [<ffffffffa03a3fb9>] br_nf_pre_routing_finish_ipv6+0x109/0x1d0 [br_netfilter]
> >     [<ffffffffa03a4400>] br_nf_pre_routing_ipv6+0xd0/0x14c [br_netfilter]
> >     [<ffffffffa03a3c27>] br_nf_pre_routing+0x197/0x3d0 [br_netfilter]
> >     [<ffffffff814a2952>] nf_iterate+0x52/0x60
> >     [<ffffffff814a29bc>] nf_hook_slow+0x5c/0xb0
> >     [<ffffffffa037ddf4>] br_handle_frame+0x1a4/0x2c0 [bridge]
> > 
> > This happens when switchdev_port_obj_add() fails. This patch
> > frees complete_info object in the fail path.
> 
> Applied, thanks.
> 

Thanks!

> I'm so glad I pushed back on your original patch :-)

man, me too !! :-)

> 
> > Cc: stable <stable@vger.kernel.org> # v4.9+
> 
> Please do not add stable tags to networking patches, I queue up and
> submit networking -stable changes myself upon request which I am doing
> in this case as well.

Oh, I see. I won't copy stable next time and I will request you to queue, when applicable.

> 
> Thanks.

-- 
All the best,
Eduardo Valentin
