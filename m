From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [Suggestion] net/core: cpumask_scnprintf, use (PAGE_SIZE - 1)
 instead of PAGE_SIZE
Date: Wed, 21 Nov 2012 16:02:00 +0800
Message-ID: <50AC8A78.6020707@asianux.com>
References: <50AC88E8.4040202@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:59896 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824Ab2KUIBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 03:01:06 -0500
In-Reply-To: <50AC88E8.4040202@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

 also for show_xps_map in net/core/net-sysfs.c


Regard

gchen


 933 static ssize_t show_xps_map(struct netdev_queue *queue,
 934                             struct netdev_queue_attribute *attribu=
te, char *buf)
 935 {
 936         struct net_device *dev =3D queue->dev;
 937         struct xps_dev_maps *dev_maps;
 938         cpumask_var_t mask;
 939         unsigned long index;
 940         size_t len =3D 0;
 941         int i;
 942=20
 943         if (!zalloc_cpumask_var(&mask, GFP_KERNEL))
 944                 return -ENOMEM;
 945=20
 946         index =3D get_netdev_queue_index(queue);
 947=20
 948         rcu_read_lock();
 949         dev_maps =3D rcu_dereference(dev->xps_maps);
 950         if (dev_maps) {
 951                 for_each_possible_cpu(i) {
 952                         struct xps_map *map =3D
 953                             rcu_dereference(dev_maps->cpu_map[i]);
 954                         if (map) {
 955                                 int j;
 956                                 for (j =3D 0; j < map->len; j++) {
 957                                         if (map->queues[j] =3D=3D =
index) {
 958                                                 cpumask_set_cpu(i,=
 mask);
 959                                                 break;
 960                                         }
 961                                 }
 962                         }
 963                 }
 964         }
 965         rcu_read_unlock();
 966=20
 967         len +=3D cpumask_scnprintf(buf + len, PAGE_SIZE, mask);
 968         if (PAGE_SIZE - len < 3) {
 969                 free_cpumask_var(mask);
 970                 return -EINVAL;
 971         }
 972=20
 973         free_cpumask_var(mask);
 974         len +=3D sprintf(buf + len, "\n");
 975         return len;
 976 }




=D3=DA 2012=C4=EA11=D4=C221=C8=D5 15:55, Chen Gang =D0=B4=B5=C0:
> Hi David Miller:
>=20
> in net/core/net-sysfs.c:
>=20
>   at line 496, we need use (PAGE_SIZE -1) instead of PAGE_SIZE.
>   since at line 505, we append '\n'.
>=20
>   regard
>=20
> gchen
>=20
>=20
>  479 static ssize_t show_rps_map(struct netdev_rx_queue *queue,
>  480                             struct rx_queue_attribute *attribute=
, char *buf)
>  481 {
>  482         struct rps_map *map;
>  483         cpumask_var_t mask;
>  484         size_t len =3D 0;
>  485         int i;
>  486=20
>  487         if (!zalloc_cpumask_var(&mask, GFP_KERNEL))
>  488                 return -ENOMEM;
>  489=20
>  490         rcu_read_lock();
>  491         map =3D rcu_dereference(queue->rps_map);
>  492         if (map)
>  493                 for (i =3D 0; i < map->len; i++)
>  494                         cpumask_set_cpu(map->cpus[i], mask);
>  495=20
>  496         len +=3D cpumask_scnprintf(buf + len, PAGE_SIZE, mask);
>  497         if (PAGE_SIZE - len < 3) {
>  498                 rcu_read_unlock();
>  499                 free_cpumask_var(mask);
>  500                 return -EINVAL;
>  501         }
>  502         rcu_read_unlock();
>  503=20
>  504         free_cpumask_var(mask);
>  505         len +=3D sprintf(buf + len, "\n");
>  506         return len;
>  507 }
>  508=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20


--=20
Chen Gang

Asianux Corporation
