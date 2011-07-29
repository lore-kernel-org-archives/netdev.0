From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
Date: Fri, 29 Jul 2011 20:02:05 +0200
Message-ID: <1311962525.2873.6.camel@edumazet-laptop>
References: <1311876249.2346.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110729164214.GI23194@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Banks <gnb-97jfqw80gc6171pxa8y+qA@public.gmane.org>
To: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110729164214.GI23194-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le vendredi 29 juillet 2011 =C3=A0 12:42 -0400, J. Bruce Fields a =C3=A9=
crit :
> On Thu, Jul 28, 2011 at 08:04:09PM +0200, Eric Dumazet wrote:
> > Use NUMA aware allocations to reduce latencies and increase through=
put.
> >=20
> > sunrpc kthreads can use kthread_create_on_node() if pool_mode is
> > "percpu" or "pernode", and svc_prepare_thread()/svc_init_buffer() c=
an
> > also take into account NUMA node affinity for memory allocations.
> ...
> > @@ -662,14 +675,16 @@ svc_set_num_threads(struct svc_serv *serv, st=
ruct svc_pool *pool, int nrservs)
> >  		nrservs--;
> >  		chosen_pool =3D choose_pool(serv, pool, &state);
> > =20
> > -		rqstp =3D svc_prepare_thread(serv, chosen_pool);
> > +		node =3D svc_pool_map_get_node(chosen_pool->sp_id);
> > +		rqstp =3D svc_prepare_thread(serv, chosen_pool, node);
>=20
> The only correct value for the third argument there is
> svc_pool_map_get_node(chosen_pool->sp_id), so let's have
> svc_prepare_thread() call that itself.
>=20

I have no idea of what you mean ;)

I need 'node' for the following kthread_create_on_node()


> Seems OK otherwise.
>=20
> Any suggestions on how we should test this?

I did tests on my machine, seems good.

I checked that stacks were now correct using :
"echo t > /proc/sysrq-trigger"



--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
