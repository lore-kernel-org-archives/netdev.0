From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6 1/4] net: introduce mc list helpers
Date: Thu, 22 Oct 2009 16:28:06 +0200
Message-ID: <20091022142806.GJ2868@psychotron.lab.eng.brq.redhat.com>
References: <20091022135120.GC2868@psychotron.lab.eng.brq.redhat.com> <20091022135220.GD2868@psychotron.lab.eng.brq.redhat.com> <1256221112.2785.13.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	e1000-devel@lists.sourceforge.net, mchehab@infradead.org,
	linux-media@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6413 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756178AbZJVO2S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2009 10:28:18 -0400
Content-Disposition: inline
In-Reply-To: <1256221112.2785.13.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 22, 2009 at 04:18:32PM CEST, bhutchings@solarflare.com wrote:
>On Thu, 2009-10-22 at 15:52 +0200, Jiri Pirko wrote:
>> This helpers should be used by network drivers to access to netdev
>> multicast lists.
>[...]
>> +static inline void netdev_mc_walk(struct net_device *dev,
>> +				  void (*func)(void *, unsigned char *),
>> +				  void *data)
>> +{
>> +	struct dev_addr_list *mclist;
>> +	int i;
>> +
>> +	for (i =3D 0, mclist =3D dev->mc_list; mclist && i < dev->mc_count=
;
>> +	     i++, mclist =3D mclist->next)
>> +		func(data, mclist->dmi_addr);
>> +}
>[...]
>
>=EF=BB=BFWe usually implement iteration as macros so that any context =
doesn't
>have to be squeezed through a single untyped (void *) variable.  A mac=
ro
>for this would look something like:
>
>#define netdev_for_each_mc_addr(dev, addr)						\
>	for (addr =3D (dev)->mc_list ? (dev)->mc_list->dmi_addr : NULL;			\
>	     addr;									\
>	     addr =3D (container_of(addr, struct dev_addr_list, dmi_addr)->ne=
xt ?		\
>		     =EF=BB=BFcontainer_of(addr, struct dev_addr_list, dmi_addr)->ne=
xt->dmi_addr : \
>		     NULL))

I admit this would look better. Going to change this and then repost.

Thanks Ben

>
>Once you change the list type this can presumably be made less ugly.
>
>Ben.
>
>--=20
>Ben Hutchings, Senior Software Engineer, Solarflare Communications
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
>
