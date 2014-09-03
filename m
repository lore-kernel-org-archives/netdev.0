From: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kvGyRCNUhGIzFRTEAbKEI=?=
	<hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net-next 4/4] ipv6: coding style - cleanse bracing
Date: Wed, 03 Sep 2014 10:31:25 +0900
Message-ID: <54066F6D.4060406@miraclelinux.com>
References: <1409685364-4327-1-git-send-email-ipm@chirality.org.uk> <1409685364-4327-5-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Ian Morris <ipm@chirality.org.uk>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og126.obsmtp.com ([64.18.2.206]:45078 "HELO
	exprod7og126.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751302AbaICBb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 21:31:29 -0400
Received: by mail-pd0-f173.google.com with SMTP id p10so9818727pdj.4
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 18:31:28 -0700 (PDT)
In-Reply-To: <1409685364-4327-5-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Ian Morris wrote:
> Tidy up braces in a few places (mainly if statements):
> * remove unnecessary braces
> * add braces for single line statements where part of an "else" where the other branch has braces

Hmm, I am not for this change.

If "if" (or "else") statement occupies multiple lines, I want to see
braces even if it contains a single statement.
On the other hand, especiallly if the statement occupiles only one line
(and the logic do not require those braces), no braces.

e.g. 1
    if (cond)
            statement();
    else {
            statement2(argument,
                       argument2);
    }
e.g. 2
    if (cond) {
            if (cond2)
                    statement();
    } else
            statement2(argument, argument2);

e.g. 3
    if (cond) {
            /* comment */
            statement();
    }

> 
> No change in the object output is detected by the objdiff script.
> 
> Signed-off-by: Ian Morris <ipm@chirality.org.uk>
> ---
>   net/ipv6/addrconf.c      |   11 +++++------
>   net/ipv6/addrconf_core.c |    3 +--
>   net/ipv6/exthdrs_core.c  |    4 ++--
>   net/ipv6/ip6_fib.c       |    4 ++--
>   net/ipv6/ip6_flowlabel.c |    3 +--
>   net/ipv6/ip6_gre.c       |    4 ++--
>   net/ipv6/ip6_input.c     |   13 +++++--------
>   net/ipv6/ip6_output.c    |   15 +++++++--------
>   net/ipv6/ip6_tunnel.c    |    6 +++---
>   net/ipv6/ip6mr.c         |   13 +++++++------
>   net/ipv6/ipv6_sockglue.c |    7 ++++---
>   net/ipv6/mcast.c         |   48 +++++++++++++++++++++++++++-------------------
>   net/ipv6/ndisc.c         |   18 ++++++-----------
>   net/ipv6/ping.c          |    8 ++++----
>   net/ipv6/route.c         |   25 +++++++++++-------------
>   net/ipv6/tcp_ipv6.c      |   10 ++++++----
>   net/ipv6/udp.c           |   20 +++++++++----------
>   net/ipv6/xfrm6_output.c  |    4 ++--
>   net/ipv6/xfrm6_tunnel.c  |    3 ++-
>   19 files changed, 108 insertions(+), 111 deletions(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 23d8493..f31a204 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -895,9 +895,9 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
>   out2:
>   	rcu_read_unlock_bh();
>   
> -	if (likely(err == 0))
> +	if (likely(err == 0)) {
>   		inet6addr_notifier_call_chain(NETDEV_UP, ifa);
> -	else {
> +	} else {
>   		kfree(ifa);
>   		ifa = ERR_PTR(err);
>   	}
> @@ -979,9 +979,9 @@ cleanup_prefix_route(struct inet6_ifaddr *ifp, unsigned long expires, bool del_r
>   				       ifp->idev->dev,
>   				       0, RTF_GATEWAY | RTF_DEFAULT);
>   	if (rt) {
> -		if (del_rt)
> +		if (del_rt) {
>   			ip6_del_rt(rt);
> -		else {
> +		} else {
>   			if (!(rt->rt6i_flags & RTF_EXPIRES))
>   				rt6_set_expires(rt, expires);
>   			ip6_rt_put(rt);
> @@ -1037,10 +1037,9 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
>   
>   	inet6addr_notifier_call_chain(NETDEV_DOWN, ifp);
>   
> -	if (action != CLEANUP_PREFIX_RT_NOP) {
> +	if (action != CLEANUP_PREFIX_RT_NOP)
>   		cleanup_prefix_route(ifp, expires,
>   			action == CLEANUP_PREFIX_RT_DEL);
> -	}
>   
>   	/* clean up prefsrc entries */
>   	rt6_remove_prefsrc(ifp);
> diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
> index e696045..cfa6739 100644
> --- a/net/ipv6/addrconf_core.c
> +++ b/net/ipv6/addrconf_core.c
> @@ -40,12 +40,11 @@ int __ipv6_addr_type(const struct in6_addr *addr)
>   		return (IPV6_ADDR_UNICAST |
>   			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));
>   
> -	if ((st & htonl(0xFF000000)) == htonl(0xFF000000)) {
> +	if ((st & htonl(0xFF000000)) == htonl(0xFF000000))
>   		/* multicast */
>   		/* addr-select 3.1 */
>   		return (IPV6_ADDR_MULTICAST |
>   			ipv6_addr_scope2type(IPV6_ADDR_MC_SCOPE(addr)));
> -	}
>   
>   	if ((st & htonl(0xFFC00000)) == htonl(0xFE800000))
>   		return (IPV6_ADDR_LINKLOCAL | IPV6_ADDR_UNICAST |
> diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
> index 2f2945d..4ffc04f 100644
> --- a/net/ipv6/exthdrs_core.c
> +++ b/net/ipv6/exthdrs_core.c
> @@ -264,9 +264,9 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
>   			if (flags && (*flags & IP6_FH_F_AUTH) && (target < 0))
>   				break;
>   			hdrlen = (hp->hdrlen + 2) << 2;
> -		} else
> +		} else {
>   			hdrlen = ipv6_optlen(hp);
> -
> +		}
>   		if (!found) {
>   			nexthdr = hp->nexthdr;
>   			len -= hdrlen;
> diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
> index 76b7f5e..17aceb6 100644
> --- a/net/ipv6/ip6_fib.c
> +++ b/net/ipv6/ip6_fib.c
> @@ -334,9 +334,9 @@ static int fib6_dump_table(struct fib6_table *table, struct sk_buff *skb,
>   			w->state = FWS_INIT;
>   			w->node = w->root;
>   			w->skip = w->count;
> -		} else
> +		} else {
>   			w->skip = 0;
> -
> +		}
>   		read_lock_bh(&table->tb6_lock);
>   		res = fib6_walk_continue(w);
>   		read_unlock_bh(&table->tb6_lock);
> diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
> index 36da541..c99a031 100644
> --- a/net/ipv6/ip6_flowlabel.c
> +++ b/net/ipv6/ip6_flowlabel.c
> @@ -162,9 +162,8 @@ static void ip6_fl_gc(unsigned long dummy)
>   	}
>   	if (!sched && atomic_read(&fl_size))
>   		sched = now + FL_MAX_LINGER;
> -	if (sched) {
> +	if (sched)
>   		mod_timer(&ip6_fl_gc_timer, sched);
> -	}
>   	spin_unlock(&ip6_fl_lock);
>   }
>   
> diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
> index 5f19dfb..7f9283f 100644
> --- a/net/ipv6/ip6_gre.c
> +++ b/net/ipv6/ip6_gre.c
> @@ -1124,8 +1124,9 @@ static int ip6gre_tunnel_ioctl(struct net_device *dev,
>   			ip6gre_tnl_parm_to_user(&p, &t->parms);
>   			if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof(p)))
>   				err = -EFAULT;
> -		} else
> +		} else {
>   			err = (cmd == SIOCADDTUNNEL ? -ENOBUFS : -ENOENT);
> +		}
>   		break;
>   
>   	case SIOCDELTUNNEL:
> @@ -1339,7 +1340,6 @@ static int __net_init ip6gre_init_net(struct net *net)
>   	 */
>   	ign->fb_tunnel_dev->features |= NETIF_F_NETNS_LOCAL;
>   
> -
>   	ip6gre_fb_tunnel_init(ign->fb_tunnel_dev);
>   	ign->fb_tunnel_dev->rtnl_link_ops = &ip6gre_link_ops;
>   
> diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
> index aacdcb4..ba3a7f8 100644
> --- a/net/ipv6/ip6_input.c
> +++ b/net/ipv6/ip6_input.c
> @@ -338,25 +338,22 @@ int ip6_mc_input(struct sk_buff *skb)
>   			/* unknown RA - process it normally */
>   		}
>   
> -		if (deliver)
> +		if (deliver) {
>   			skb2 = skb_clone(skb, GFP_ATOMIC);
> -		else {
> +		} else {
>   			skb2 = skb;
>   			skb = NULL;
>   		}
>   
> -		if (skb2) {
> +		if (skb2)
>   			ip6_mr_input(skb2);
> -		}
>   	}
>   out:
>   #endif
>   	if (likely(deliver))
>   		ip6_input(skb);
> -	else {
> -		/* discard */
> -		kfree_skb(skb);
> -	}
> +	else
> +		kfree_skb(skb); /* discard */
>   
>   	return 0;
>   }
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 86fc687..5e520f2 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -275,9 +275,9 @@ static int ip6_forward_proxy_check(struct sk_buff *skb)
>   		offset = ipv6_skip_exthdr(skb, sizeof(*hdr), &nexthdr, &frag_off);
>   		if (offset < 0)
>   			return 0;
> -	} else
> +	} else {
>   		offset = sizeof(struct ipv6hdr);
> -
> +	}
>   	if (nexthdr == IPPROTO_ICMPV6) {
>   		struct icmp6hdr *icmp6;
>   
> @@ -388,7 +388,7 @@ int ip6_forward(struct sk_buff *skb)
>   	/*
>   	 *	We DO NOT make any processing on
>   	 *	RA packets, pushing them to user level AS IS
> -	 *	without ane WARRANTY that application will be able
> +	 *	without any WARRANTY that application will be able
>   	 *	to interpret them. The reason is that we
>   	 *	cannot make anything clever here.
>   	 *
> @@ -741,16 +741,15 @@ slow_path:
>   	/*
>   	 *	Keep copying data until we run out.
>   	 */
> -	while (left > 0)	{
> +	while (left > 0) {
>   		len = left;
>   		/* IF: it doesn't fit, use 'mtu' - the data space left */
>   		if (len > mtu)
>   			len = mtu;
>   		/* IF: we are not sending up to and including the packet end
>   		   then align the next start on an eight byte boundary */
> -		if (len < left)	{
> +		if (len < left)
>   			len &= ~7;
> -		}
>   		/*
>   		 *	Allocate buffer.
>   		 */
> @@ -795,9 +794,9 @@ slow_path:
>   		if (!frag_id) {
>   			ipv6_select_ident(fh, rt);
>   			frag_id = fh->identification;
> -		} else
> +		} else {
>   			fh->identification = frag_id;
> -
> +		}
>   		/*
>   		 *	Copy a block of the IP datagram.
>   		 */
> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> index b38cc18..488f0dc 100644
> --- a/net/ipv6/ip6_tunnel.c
> +++ b/net/ipv6/ip6_tunnel.c
> @@ -1362,9 +1362,8 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>   			memset(&p, 0, sizeof(p));
>   		}
>   		ip6_tnl_parm_to_user(&p, &t->parms);
> -		if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof(p))) {
> +		if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof(p)))
>   			err = -EFAULT;
> -		}
>   		break;
>   	case SIOCADDTUNNEL:
>   	case SIOCCHGTUNNEL:
> @@ -1640,8 +1639,9 @@ static int ip6_tnl_changelink(struct net_device *dev, struct nlattr *tb[],
>   	if (t) {
>   		if (t->dev != dev)
>   			return -EEXIST;
> -	} else
> +	} else {
>   		t = netdev_priv(dev);
> +	}
>   
>   	return ip6_tnl_update(t, &p);
>   }
> diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
> index 0171f08..ea054d5 100644
> --- a/net/ipv6/ip6mr.c
> +++ b/net/ipv6/ip6mr.c
> @@ -853,8 +853,9 @@ static void ip6mr_destroy_unres(struct mr6_table *mrt, struct mfc6_cache *c)
>   			skb_trim(skb, nlh->nlmsg_len);
>   			((struct nlmsgerr *)nlmsg_data(nlh))->error = -ETIMEDOUT;
>   			rtnl_unicast(skb, net, NETLINK_CB(skb).portid);
> -		} else
> +		} else {
>   			kfree_skb(skb);
> +		}
>   	}
>   
>   	ip6mr_cache_free(c);
> @@ -1116,8 +1117,9 @@ static void ip6mr_cache_resolve(struct net *net, struct mr6_table *mrt,
>   				((struct nlmsgerr *)nlmsg_data(nlh))->error = -EMSGSIZE;
>   			}
>   			rtnl_unicast(skb, net, NETLINK_CB(skb).portid);
> -		} else
> +		} else {
>   			ip6_mr_forward(net, mrt, skb, c);
> +		}
>   	}
>   }
>   
> @@ -1591,9 +1593,9 @@ static int ip6mr_sk_init(struct mr6_table *mrt, struct sock *sk)
>   		inet6_netconf_notify_devconf(net, NETCONFA_MC_FORWARDING,
>   					     NETCONFA_IFINDEX_ALL,
>   					     net->ipv6.devconf_all);
> -	}
> -	else
> +	} else {
>   		err = -EADDRINUSE;
> +	}
>   	write_unlock_bh(&mrt_lock);
>   
>   	rtnl_unlock();
> @@ -2406,8 +2408,7 @@ static int mr6_msgsize(bool unresolved, int maxvif)
>   		      + nla_total_size(0)	/* RTA_MULTIPATH */
>   		      + maxvif * NLA_ALIGN(sizeof(struct rtnexthop))
>   						/* RTA_MFC_STATS */
> -		      + nla_total_size(sizeof(struct rta_mfc_stats))
> -		;
> +		      + nla_total_size(sizeof(struct rta_mfc_stats));
>   
>   	return len;
>   }
> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
> index e1a9583..8811f84 100644
> --- a/net/ipv6/ipv6_sockglue.c
> +++ b/net/ipv6/ipv6_sockglue.c
> @@ -129,14 +129,15 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
>   	int val, valbool;
>   	int retv = -ENOPROTOOPT;
>   
> -	if (optval == NULL)
> +	if (optval == NULL) {
>   		val = 0;
> -	else {
> +	} else {
>   		if (optlen >= sizeof(int)) {
>   			if (get_user(val, (int __user *) optval))
>   				return -EFAULT;
> -		} else
> +		} else {
>   			val = 0;
> +		}
>   	}
>   
>   	valbool = (val != 0);
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index 7088179..2eb811e 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -180,9 +180,9 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
>   			dev = rt->dst.dev;
>   			ip6_rt_put(rt);
>   		}
> -	} else
> +	} else {
>   		dev = dev_get_by_index_rcu(net, ifindex);
> -
> +	}
>   	if (dev == NULL) {
>   		rcu_read_unlock();
>   		sock_kfree_s(sk, mc_lst, sizeof(*mc_lst));
> @@ -277,9 +277,9 @@ static struct inet6_dev *ip6_mc_find_dev_rcu(struct net *net,
>   			dev = rt->dst.dev;
>   			ip6_rt_put(rt);
>   		}
> -	} else
> +	} else {
>   		dev = dev_get_by_index_rcu(net, ifindex);
> -
> +	}
>   	if (!dev)
>   		return NULL;
>   	idev = __in6_dev_get(dev);
> @@ -318,8 +318,9 @@ void ipv6_sock_mc_close(struct sock *sk)
>   			(void) ip6_mc_leave_src(sk, mc_lst, idev);
>   			if (idev)
>   				__ipv6_dev_mc_dec(idev, &mc_lst->addr);
> -		} else
> +		} else {
>   			(void) ip6_mc_leave_src(sk, mc_lst, NULL);
> +		}
>   		rcu_read_unlock();
>   
>   		atomic_sub(sizeof(*mc_lst), &sk->sk_omem_alloc);
> @@ -537,8 +538,9 @@ int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf)
>   		(void) ip6_mc_del_src(idev, group, pmc->sfmode,
>   			psl->sl_count, psl->sl_addr, 0);
>   		sock_kfree_s(sk, psl, IP6_SFLSIZE(psl->sl_max));
> -	} else
> +	} else {
>   		(void) ip6_mc_del_src(idev, group, pmc->sfmode, 0, NULL, 0);
> +	}
>   	pmc->sflist = newpsl;
>   	pmc->sfmode = gsf->gf_fmode;
>   	write_unlock(&pmc->sflock);
> @@ -1359,9 +1361,9 @@ int igmp6_event_query(struct sk_buff *skb)
>   			mlh2 = (struct mld2_query *)skb_transport_header(skb);
>   			mark = 1;
>   		}
> -	} else
> +	} else {
>   		return -EINVAL;
> -
> +	}
>   	read_lock_bh(&idev->lock);
>   	if (group_type == IPV6_ADDR_ANY) {
>   		for (ma = idev->mc_list; ma; ma = ma->next) {
> @@ -1832,8 +1834,9 @@ static void mld_clear_zeros(struct ip6_sf_list **ppsf)
>   			else
>   				*ppsf = psf->sf_next;
>   			kfree(psf);
> -		} else
> +		} else {
>   			psf_prev = psf;
> +		}
>   	}
>   }
>   
> @@ -1875,8 +1878,9 @@ static void mld_send_cr(struct inet6_dev *idev)
>   				idev->mc_tomb = pmc_next;
>   			in6_dev_put(pmc->idev);
>   			kfree(pmc);
> -		} else
> +		} else {
>   			pmc_prev = pmc;
> +		}
>   	}
>   	spin_unlock(&idev->mc_lock);
>   
> @@ -1960,9 +1964,9 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
>   		 * when a valid link-local address is not available.
>   		 */
>   		saddr = &in6addr_any;
> -	} else
> +	} else {
>   		saddr = &addr_buf;
> -
> +	}
>   	ip6_mc_hdr(sk, skb, dev, saddr, snd_addr, NEXTHDR_HOP, payload_len);
>   
>   	memcpy(skb_put(skb, sizeof(ra)), ra, sizeof(ra));
> @@ -1996,9 +2000,9 @@ out:
>   		ICMP6MSGOUT_INC_STATS(net, idev, type);
>   		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
>   		IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUTMCAST, full_len);
> -	} else
> +	} else {
>   		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTDISCARDS);
> -
> +	}
>   	rcu_read_unlock();
>   	return;
>   
> @@ -2087,8 +2091,9 @@ static int ip6_mc_del1_src(struct ifmcaddr6 *pmc, int sfmode,
>   			psf->sf_next = pmc->mca_tomb;
>   			pmc->mca_tomb = psf;
>   			rv = 1;
> -		} else
> +		} else {
>   			kfree(psf);
> +		}
>   	}
>   	return rv;
>   }
> @@ -2143,8 +2148,9 @@ static int ip6_mc_del_src(struct inet6_dev *idev, const struct in6_addr *pmca,
>   		for (psf = pmc->mca_sources; psf; psf = psf->sf_next)
>   			psf->sf_crcount = 0;
>   		mld_ifc_event(pmc->idev);
> -	} else if (sf_setstate(pmc) || changerec)
> +	} else if (sf_setstate(pmc) || changerec) {
>   		mld_ifc_event(pmc->idev);
> +	}
>   	spin_unlock_bh(&pmc->mca_lock);
>   	read_unlock_bh(&idev->lock);
>   	return err;
> @@ -2170,9 +2176,9 @@ static int ip6_mc_add1_src(struct ifmcaddr6 *pmc, int sfmode,
>   			return -ENOBUFS;
>   
>   		psf->sf_addr = *psfsrc;
> -		if (psf_prev) {
> +		if (psf_prev)
>   			psf_prev->sf_next = psf;
> -		} else
> +		else
>   			pmc->mca_sources = psf;
>   	}
>   	psf->sf_count[sfmode]++;
> @@ -2189,8 +2195,9 @@ static void sf_markstate(struct ifmcaddr6 *pmc)
>   			psf->sf_oldin = mca_xcount ==
>   				psf->sf_count[MCAST_EXCLUDE] &&
>   				!psf->sf_count[MCAST_INCLUDE];
> -		} else
> +		} else {
>   			psf->sf_oldin = psf->sf_count[MCAST_INCLUDE] != 0;
> +		}
>   }
>   
>   static int sf_setstate(struct ifmcaddr6 *pmc)
> @@ -2311,8 +2318,9 @@ static int ip6_mc_add_src(struct inet6_dev *idev, const struct in6_addr *pmca,
>   		for (psf = pmc->mca_sources; psf; psf = psf->sf_next)
>   			psf->sf_crcount = 0;
>   		mld_ifc_event(idev);
> -	} else if (sf_setstate(pmc))
> +	} else if (sf_setstate(pmc)) {
>   		mld_ifc_event(idev);
> +	}
>   	spin_unlock_bh(&pmc->mca_lock);
>   	read_unlock_bh(&idev->lock);
>   	return err;
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index d0232b2..a38d730 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -303,9 +303,8 @@ static int ndisc_constructor(struct neighbour *neigh)
>   	bool is_multicast = ipv6_addr_is_multicast(addr);
>   
>   	in6_dev = in6_dev_get(dev);
> -	if (in6_dev == NULL) {
> +	if (in6_dev == NULL)
>   		return -EINVAL;
> -	}
>   
>   	parms = in6_dev->nd_parms;
>   	__neigh_parms_put(neigh->parms);
> @@ -604,9 +603,8 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
>   		struct inet6_ifaddr *ifp = ipv6_get_ifaddr(dev_net(dev), saddr,
>   							   dev, 1);
>   		if (ifp) {
> -			if (ifp->flags & IFA_F_OPTIMISTIC)  {
> +			if (ifp->flags & IFA_F_OPTIMISTIC)
>   				send_sllao = 0;
> -			}
>   			in6_ifa_put(ifp);
>   		} else {
>   			send_sllao = 0;
> @@ -805,8 +803,9 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>   					pneigh_enqueue(&nd_tbl, idev->nd_parms, n);
>   				goto out;
>   			}
> -		} else
> +		} else {
>   			goto out;
> +		}
>   	}
>   
>   	if (is_router < 0)
> @@ -865,18 +864,15 @@ static void ndisc_recv_na(struct sk_buff *skb)
>   		ND_PRINTK(2, warn, "NA: packet too short\n");
>   		return;
>   	}
> -
>   	if (ipv6_addr_is_multicast(&msg->target)) {
>   		ND_PRINTK(2, warn, "NA: target address is multicast\n");
>   		return;
>   	}
> -
>   	if (ipv6_addr_is_multicast(daddr) &&
>   	    msg->icmph.icmp6_solicited) {
>   		ND_PRINTK(2, warn, "NA: solicited NA is multicasted\n");
>   		return;
>   	}
> -
>   	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts)) {
>   		ND_PRINTK(2, warn, "NS: invalid ND option\n");
>   		return;
> @@ -1026,9 +1022,8 @@ static void ndisc_ra_useropt(struct sk_buff *ra, struct nd_opt_hdr *opt)
>   	}
>   
>   	nlh = nlmsg_put(skb, 0, 0, RTM_NEWNDUSEROPT, base_size, 0);
> -	if (nlh == NULL) {
> +	if (nlh == NULL)
>   		goto nla_put_failure;
> -	}
>   
>   	ndmsg = nlmsg_data(nlh);
>   	ndmsg->nduseropt_family = AF_INET6;
> @@ -1376,9 +1371,8 @@ skip_routeinfo:
>   		}
>   	}
>   
> -	if (ndopts.nd_opts_tgt_lladdr || ndopts.nd_opts_rh) {
> +	if (ndopts.nd_opts_tgt_lladdr || ndopts.nd_opts_rh)
>   		ND_PRINTK(2, warn, "RA: invalid RA options\n");
> -	}
>   out:
>   	ip6_rt_put(rt);
>   	if (neigh)
> diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
> index 5b7a1ed..b1274f4 100644
> --- a/net/ipv6/ping.c
> +++ b/net/ipv6/ping.c
> @@ -103,13 +103,13 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
>   	if (msg->msg_name) {
>   		DECLARE_SOCKADDR(struct sockaddr_in6 *, u, msg->msg_name);
>   		if (msg->msg_namelen < sizeof(struct sockaddr_in6) ||
> -		    u->sin6_family != AF_INET6) {
> +		    u->sin6_family != AF_INET6)
>   			return -EINVAL;
> -		}
> +
>   		if (sk->sk_bound_dev_if &&
> -		    sk->sk_bound_dev_if != u->sin6_scope_id) {
> +		    sk->sk_bound_dev_if != u->sin6_scope_id)
>   			return -EINVAL;
> -		}
> +
>   		daddr = &(u->sin6_addr);
>   		iif = u->sin6_scope_id;
>   	} else {
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index f74b041..0b924e3 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -708,9 +708,8 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
>   	unsigned long lifetime;
>   	struct rt6_info *rt;
>   
> -	if (len < sizeof(struct route_info)) {
> +	if (len < sizeof(struct route_info))
>   		return -EINVAL;
> -	}
>   
>   	/* Sanity check for prefix_len and length */
>   	if (rinfo->length > 3) {
> @@ -718,13 +717,11 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
>   	} else if (rinfo->prefix_len > 128) {
>   		return -EINVAL;
>   	} else if (rinfo->prefix_len > 64) {
> -		if (rinfo->length < 2) {
> +		if (rinfo->length < 2)
>   			return -EINVAL;
> -		}
>   	} else if (rinfo->prefix_len > 0) {
> -		if (rinfo->length < 1) {
> +		if (rinfo->length < 1)
>   			return -EINVAL;
> -		}
>   	}
>   
>   	pref = rinfo->route_pref;
> @@ -733,9 +730,9 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
>   
>   	lifetime = addrconf_timeout_fixup(ntohl(rinfo->lifetime), HZ);
>   
> -	if (rinfo->length == 3)
> +	if (rinfo->length == 3) {
>   		prefix = (struct in6_addr *)rinfo->prefix;
> -	else {
> +	} else {
>   		/* this function is safe */
>   		ipv6_addr_prefix(&prefix_buf,
>   				 (struct in6_addr *)rinfo->prefix,
> @@ -2578,13 +2575,13 @@ static int rt6_fill_node(struct net *net,
>   			rtm->rtm_type = RTN_UNREACHABLE;
>   			break;
>   		}
> -	}
> -	else if (rt->rt6i_flags & RTF_LOCAL)
> +	} else if (rt->rt6i_flags & RTF_LOCAL) {
>   		rtm->rtm_type = RTN_LOCAL;
> -	else if (rt->dst.dev && (rt->dst.dev->flags & IFF_LOOPBACK))
> +	} else if (rt->dst.dev && (rt->dst.dev->flags & IFF_LOOPBACK)) {
>   		rtm->rtm_type = RTN_LOCAL;
> -	else
> +	} else {
>   		rtm->rtm_type = RTN_UNICAST;
> +	}
>   	rtm->rtm_flags = 0;
>   	rtm->rtm_scope = RT_SCOPE_UNIVERSE;
>   	rtm->rtm_protocol = rt->rt6i_protocol;
> @@ -2682,9 +2679,9 @@ int rt6_dump_route(struct rt6_info *rt, void *p_arg)
>   	if (nlmsg_len(arg->cb->nlh) >= sizeof(struct rtmsg)) {
>   		struct rtmsg *rtm = nlmsg_data(arg->cb->nlh);
>   		prefix = (rtm->rtm_flags & RTM_F_PREFIX) != 0;
> -	} else
> +	} else {
>   		prefix = 0;
> -
> +	}
>   	return rt6_fill_node(arg->net,
>   		     arg->skb, rt, NULL, NULL, 0, RTM_NEWROUTE,
>   		     NETLINK_CB(arg->cb->skb).portid, arg->cb->nlh->nlmsg_seq,
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 29964c3..2790300 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -454,16 +454,18 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
>   			sk->sk_error_report(sk);		/* Wake people up to see the error (see connect in sock.c) */
>   
>   			tcp_done(sk);
> -		} else
> +		} else {
>   			sk->sk_err_soft = err;
> +		}
>   		goto out;
>   	}
>   
>   	if (!sock_owned_by_user(sk) && np->recverr) {
>   		sk->sk_err = err;
>   		sk->sk_error_report(sk);
> -	} else
> +	} else {
>   		sk->sk_err_soft = err;
> +	}
>   
>   out:
>   	bh_unlock_sock(sk);
> @@ -1323,9 +1325,9 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
>   				__kfree_skb(opt_skb);
>   			return 0;
>   		}
> -	} else
> +	} else {
>   		sock_rps_save_rxhash(sk, skb);
> -
> +	}
>   	if (tcp_rcv_state_process(sk, skb, tcp_hdr(skb), skb->len))
>   		goto reset;
>   	if (opt_skb)
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index e06d460..d59c723 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -424,10 +424,10 @@ try_again:
>   			goto csum_copy_err;
>   	}
>   
> -	if (skb_csum_unnecessary(skb))
> +	if (skb_csum_unnecessary(skb)) {
>   		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr),
>   					      msg->msg_iov, copied);
> -	else {
> +	} else {
>   		err = skb_copy_and_csum_datagram_iovec(skb, sizeof(struct udphdr), msg->msg_iov);
>   		if (err == -EINVAL)
>   			goto csum_copy_err;
> @@ -488,7 +488,6 @@ try_again:
>   		if (np->rxopt.all)
>   			ip6_datagram_recv_specific_ctl(sk, msg, skb);
>   	}
> -
>   	err = copied;
>   	if (flags & MSG_TRUNC)
>   		err = ulen;
> @@ -819,11 +818,10 @@ start_lookup:
>   		goto start_lookup;
>   	}
>   
> -	if (count) {
> +	if (count)
>   		flush_stack(stack, count, skb, count - 1);
> -	} else {
> +	else
>   		kfree_skb(skb);
> -	}
>   	return 0;
>   }
>   
> @@ -1061,9 +1059,10 @@ send:
>   					    UDP_MIB_SNDBUFERRORS, is_udplite);
>   			err = 0;
>   		}
> -	} else
> +	} else {
>   		UDP6_INC_STATS_USER(sock_net(sk),
>   				    UDP_MIB_OUTDATAGRAMS, is_udplite);
> +	}
>   out:
>   	up->len = 0;
>   	up->pending = 0;
> @@ -1119,9 +1118,9 @@ int udpv6_sendmsg(struct kiocb *iocb, struct sock *sk,
>   		if (sk->sk_state != TCP_ESTABLISHED)
>   			return -EDESTADDRREQ;
>   		daddr = &sk->sk_v6_daddr;
> -	} else
> +	} else {
>   		daddr = NULL;
> -
> +	}
>   	if (daddr) {
>   		if (ipv6_addr_v4mapped(daddr)) {
>   			struct sockaddr_in sin;
> @@ -1453,7 +1452,8 @@ int __net_init udp6_proc_init(struct net *net)
>   	return udp_proc_register(net, &udp6_seq_afinfo);
>   }
>   
> -void udp6_proc_exit(struct net *net) {
> +void udp6_proc_exit(struct net *net)
> +{
>   	udp_proc_unregister(net, &udp6_seq_afinfo);
>   }
>   #endif /* CONFIG_PROC_FS */
> diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
> index ca3f29b..f9f745d 100644
> --- a/net/ipv6/xfrm6_output.c
> +++ b/net/ipv6/xfrm6_output.c
> @@ -159,9 +159,9 @@ static int __xfrm6_output(struct sk_buff *skb)
>   
>   	if (x->props.mode == XFRM_MODE_TUNNEL &&
>   	    ((skb->len > mtu && !skb_is_gso(skb)) ||
> -		dst_allfrag(skb_dst(skb)))) {
> +		dst_allfrag(skb_dst(skb))))
>   			return ip6_fragment(skb, x->outer_mode->afinfo->output_finish);
> -	}
> +
>   	return x->outer_mode->afinfo->output_finish(skb);
>   }
>   
> diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
> index 5743044..2965098 100644
> --- a/net/ipv6/xfrm6_tunnel.c
> +++ b/net/ipv6/xfrm6_tunnel.c
> @@ -180,8 +180,9 @@ __be32 xfrm6_tunnel_alloc_spi(struct net *net, xfrm_address_t *saddr)
>   	if (x6spi) {
>   		atomic_inc(&x6spi->refcnt);
>   		spi = x6spi->spi;
> -	} else
> +	} else {
>   		spi = __xfrm6_tunnel_alloc_spi(net, saddr);
> +	}
>   	spin_unlock_bh(&xfrm6_tunnel_spi_lock);
>   
>   	return htonl(spi);
> 

-- 
吉藤英明 <hideaki.yoshifuji@miraclelinux.com>
ミラクル・リナックス株式会社 技術本部 サポート部
