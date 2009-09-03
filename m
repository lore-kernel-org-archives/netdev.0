From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] slub: Fix kmem_cache_destroy() with SLAB_DESTROY_BY_RCU
Date: Thu, 03 Sep 2009 21:56:04 +0200
Message-ID: <4AA01F54.4040808@gmail.com>
References: <c4e36d110908110542l3de51aaepcbd62c84b9848f2b@mail.gmail.com>	 <4A9EEF07.5070800@gmail.com>	 <c4e36d110909021531v324a9ce2x3ff2c93b7c5a57de@mail.gmail.com>	 <4A9F1620.2080105@gmail.com>	 <84144f020909022331x2b275aa5n428f88670e0ae8bc@mail.gmail.com>	 <4A9F7283.1090306@gmail.com>	 <84144f020909030051u6cf6ae01he25c268f718ff3af@mail.gmail.com>	 <alpine.DEB.1.10.0909031246010.27903@V090114053VZO-1>	 <84144f020909030705x7909cf07w7ea0d3662a66c5cc@mail.gmail.com>	 <4A9FD047.9000002@gmail.com> <84144f020909031248s56c16205j7992930c413b1bbe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux-foundation.org>,
	Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	Patrick McHardy <kaber@trash.net>, Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	paulmck@linux.vnet.ibm.com, "stable@kernel.org" <stable@kernel.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <84144f020909031248s56c16205j7992930c413b1bbe@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pekka Enberg a =E9crit :
> On Thu, Sep 3, 2009 at 5:18 PM, Eric Dumazet<eric.dumazet@gmail.com> =
wrote:
>> Here is the second patch (RCU thing). Stable candidate
>>
>> [PATCH] slub: Fix kmem_cache_destroy() with SLAB_DESTROY_BY_RCU
>>
>> kmem_cache_destroy() should call rcu_barrier() *after* kmem_cache_cl=
ose()
>> and *before* sysfs_slab_remove() or risk rcu_free_slab()
>> being called after kmem_cache is deleted (kfreed).
>>
>> rmmod nf_conntrack can crash the machine because it has to
>> kmem_cache_destroy() a SLAB_DESTROY_BY_RCU enabled cache.
>=20
> Do we have a bugzilla URL for this?

Well, I can crash my 2.6.30.5 machine just doing rmmod nf_conntrack

(You'll need CONFIG_SLUB_DEBUG_ON or equivalent)

Original Zdenek report : http://thread.gmane.org/gmane.linux.kernel/876=
016/focus=3D876086

>=20
>> Reported-by: Zdenek Kabelac <zdenek.kabelac@gmail.com>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>=20
> OK, this is in for-next now and queued for 2.6.31. If you guys want t=
o
> fix this in a different way, lets do that in 2.6.32.

Seems the right thing IMHO
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
