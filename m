From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 1/4] net: introduce mc list helpers
Date: Thu, 22 Oct 2009 15:18:32 +0100
Message-ID: <1256221112.2785.13.camel@achroite>
References: <20091022135120.GC2868@psychotron.lab.eng.brq.redhat.com>
	 <20091022135220.GD2868@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	e1000-devel@lists.sourceforge.net, mchehab@infradead.org,
	linux-media@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:53672 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754812AbZJVOSc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 10:18:32 -0400
In-Reply-To: <20091022135220.GD2868@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-10-22 at 15:52 +0200, Jiri Pirko wrote:
> This helpers should be used by network drivers to access to netdev
> multicast lists.
[...]
> +static inline void netdev_mc_walk(struct net_device *dev,
> +				  void (*func)(void *, unsigned char *),
> +				  void *data)
> +{
> +	struct dev_addr_list *mclist;
> +	int i;
> +
> +	for (i =3D 0, mclist =3D dev->mc_list; mclist && i < dev->mc_count;
> +	     i++, mclist =3D mclist->next)
> +		func(data, mclist->dmi_addr);
> +}
[...]

=EF=BB=BFWe usually implement iteration as macros so that any context d=
oesn't
have to be squeezed through a single untyped (void *) variable.  A macr=
o
for this would look something like:

#define netdev_for_each_mc_addr(dev, addr)						\
	for (addr =3D (dev)->mc_list ? (dev)->mc_list->dmi_addr : NULL;			\
	     addr;									\
	     addr =3D (container_of(addr, struct dev_addr_list, dmi_addr)->nex=
t ?		\
		     =EF=BB=BFcontainer_of(addr, struct dev_addr_list, dmi_addr)->nex=
t->dmi_addr : \
		     NULL))

Once you change the list type this can presumably be made less ugly.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

