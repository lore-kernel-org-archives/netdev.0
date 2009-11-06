From: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 19/25] mlx4: Randomizing mac addresses for slaves
Date: Thu, 05 Nov 2009 22:08:58 -0800
Message-ID: <adaeiocyykl.fsf@roland-alpha.cisco.com>
References: <4AF19E69.8070605@mellanox.co.il> <adar5seys3e.fsf@cisco.com>
	<15ddcffd0911041333l165ee274mfae3508a3db755e7@mail.gmail.com>
	<2ED289D4E09FBD4D92D911E869B97FDD0166CA59@mtlexch01.mtl.com>
	<adabpjhc6az.fsf@roland-alpha.cisco.com>
	<20091106040624.GA6629@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Tziporet Koren <tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20091106040624.GA6629-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> (Simon Horman's message of
	"Fri, 6 Nov 2009 15:06:24 +1100")
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


 > > igb uses the full output of random_ether_addr().  I'd be fine with
 > > that.  However setting the OUI means you only get 24 bits of randomness
 > > which makes a collision a lot more likely.
 > 
 > IIRC that was precisely why the OUI isn't used for the igb driver.
 > 
 > Perhaps some infrastructure (by which I mean a random_mac() function)
 > is warranted so at least this discussion can be concentrated around that
 > rather than repeating it for each driver that needs random mac addresses.

What would be the difference between random_mac() and the existing
random_ether_addr() function?

If one chooses a random address with a given OUI, then with only 24 bits
of randomness, the birthday paradox says it takes only a few thousand
addresses to get a collision (easy to hit given even a modest-sized
virtualization setup).  With the 46 bits that random_ether_addr() gives
it takes millions of addresses to be likely to get a collision, which is
probably comfortable for most ethernets.

So it seems that random_ether_addr() is exactly what we should be using
for VFs -- the only alternative I see is for the manufacturer to
allocate N extra ethernet addresses for a NIC that supports N virtual
functions, and use those assigned addresses.  But if the kernel is
making up ethernet addresses then we better use all the bits we can.

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
