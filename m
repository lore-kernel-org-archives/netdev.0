From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hv_netvsc: don't make assumptions on struct
 flow_keys layout
Date: Fri, 8 Jan 2016 21:07:58 +0000
Message-ID: <DM2PR0301MB0784EBC7C507C17E596D87C0CAF60@DM2PR0301MB0784.namprd03.prod.outlook.com>
References: <1452159189-11473-1-git-send-email-vkuznets@redhat.com>
 <1452171150.8255.207.camel@edumazet-glaptop2.roam.corp.google.com>
 <877fjlfrid.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 David Miller <davem@davemloft.net>
To: Vitaly Kuznetsov <vkuznets@redhat.com>, Simon Xiao <sixiao@microsoft.com>,
 Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <877fjlfrid.fsf@vitty.brq.redhat.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Vitaly Kuznetsov [mailto:vkuznets@redhat.com]
> Sent: Thursday, January 7, 2016 8:28 AM
> To: Simon Xiao <sixiao@microsoft.com>; Eric Dumazet
> <eric.dumazet@gmail.com>
> Cc: Tom Herbert <tom@herbertland.com>; netdev@vger.kernel.org; KY
> Srinivasan <kys@microsoft.com>; Haiyang Zhang <haiyangz@microsoft.com>;
> devel@linuxdriverproject.org; linux-kernel@vger.kernel.org; David Miller
> <davem@davemloft.net>
> Subject: Re: [PATCH net-next] hv_netvsc: don't make assumptions on
> struct flow_keys layout
> 
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> 
> > On Thu, 2016-01-07 at 10:33 +0100, Vitaly Kuznetsov wrote:
> >> Recent changes to 'struct flow_keys' (e.g commit d34af823ff40 ("net:
> Add
> >>  VLAN ID to flow_keys")) introduced a performance regression in
> netvsc
> >> driver. Is problem is, however, not the above mentioned commit but
> the
> >> fact that netvsc_set_hash() function did some assumptions on the
> struct
> >> flow_keys data layout and this is wrong. We need to extract the data
> we
> >> need (src/dst addresses and ports) after the dissect.
> >>
> >> The issue could also be solved in a completely different way: as
> suggested
> >> by Eric instead of our own homegrown netvsc_set_hash() we could use
> >> skb_get_hash() which does more or less the same. Unfortunately, the
> >> testing done by Simon showed that Hyper-V hosts are not happy with
> our
> >> Jenkins hash, selecting the output queue with the current algorithm
> based
> >> on Toeplitz hash works significantly better.
> >
> > Were tests done on IPv6 traffic ?
> >
> 
> Simon, could you please test this patch for IPv6 and show us the numbers?
> 
> > Toeplitz hash takes at least 100 ns to hash 12 bytes (one iteration
> per
> > bit : 96 iterations)
> >
> > For IPv6 it is 3 times this, since we have to hash 36 bytes.
> >
> > I do not see how it can compete with skb_get_hash() that directly
> gives
> > skb->hash for local TCP flows.
> >
> 
> My guess is that this is not the bottleneck, something is happening
> behind the scene with out packets in Hyper-V host (e.g. re-distributing
> them to hardware queues?) but I don't know the internals, Microsoft
> folks could probably comment.

The Hyper-V vRSS protocol lets us use the Toeplitz hash algorithm. We are
currently running further tests, including IPv6 too, and will share the 
results when available.

Thanks,
- Haiyang
