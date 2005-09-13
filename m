From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: [patch 7/11] net: Use bigrefs for net_device.refcount
Date: Tue, 13 Sep 2005 11:53:48 -0700
Message-ID: <20050913185348.GA3724@localhost.localdomain>
References: <20050913155112.GB3570@localhost.localdomain> <20050913161012.GI3570@localhost.localdomain> <43271A28.9090301@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	dipankar@in.ibm.com, bharata@in.ibm.com, shai@scalex86.org,
	Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964989AbVIMSxz@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <43271A28.9090301@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 13, 2005 at 08:27:52PM +0200, Eric Dumazet wrote:
> Ravikiran G Thirumalai a =E9crit :
>=20
> Hum...
>=20
> Did you tried to place refcnt/netdev_refcnt in a separate cache line =
than=20
> queue_lock ? I got good results too...
>=20
> >  	/* device queue lock */
> >  	spinlock_t		queue_lock;
> >  	/* Number of references to this device */
> > -	atomic_t		refcnt;
> > +	struct bigref	        netdev_refcnt ____cacheline_aligned_in_smp =
;=20
> >  	/* delayed register/unregister */
> >  	struct list_head	todo_list;
> >  	/* device name hash chain */
>=20
> Every time a cpu take the queue_lock spinlock, it exclusively gets on=
e=20
> cache line. If another cpu try to access netdev_refcnt, it has to gra=
b this=20
> cache line (even if properely per_cpu designed, there is still one sh=
ared=20
> field). In fact the whole struct net_device should be re-ordered for=20
> SMP/NUMA performance.

I agree. Maybe placing the queue_lock in a different cacheline is the=20
right approach?

Thanks,
Kiran
