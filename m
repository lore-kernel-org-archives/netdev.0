From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH -next] batadv: Slight optimization of
	batadv_compare_eth
Date: Fri, 06 Dec 2013 13:17:01 -0800
Message-ID: <1386364621.31845.32.camel@joe-AO722>
References: <1386317890.31845.26.camel@joe-AO722>
 <20131206.153944.1382127535160341376.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20131206.153944.1382127535160341376.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Fri, 2013-12-06 at 15:39 -0500, David Miller wrote:
> From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
> Date: Fri, 06 Dec 2013 00:18:10 -0800
> 
> > @@ -266,7 +266,11 @@ static inline void batadv_dbg(int type __always_unused,
> >   */
> >  static inline int batadv_compare_eth(const void *data1, const void *data2)
> >  {
> > -	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
> > +#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
> > +	return ether_addr_equal(data1, data2);
> > +#else
> > +	return memcmp(data1, data2, ETH_ALEN) == 0;
> > +#endif
> >  }
> 
> Let's not crap up implementations with these ifdefs.
> 
> What's the specific situation here?  Is it that 'data1' and/or
> 'data2' my not be u16 aligned?

Yes.

> If so, make a function for that in linux/etherdevice.h and invoke it
> in such places.  You can name it something like
> "ether_addr_equal_unaligned()" or similar.

I'll resubmit if/after you apply the
ether_addr_equal/compare_ether_addr removal.

cheers, Joe
