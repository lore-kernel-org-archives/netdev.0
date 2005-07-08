From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Fri, 08 Jul 2005 10:19:46 +0200
Message-ID: <42CE3722.3070208@cosmosbay.com>
References: <20050706124206.GW16076@postel.suug.ch>	<20050707.141718.85410359.davem@davemloft.net>	<42CE22CE.7030902@cosmosbay.com> <20050708.003014.125896217.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: tgraf@suug.ch, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050708.003014.125896217.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Fri, 08 Jul 2005 08:53:02 +0200
>=20
>=20
>>About making sk_buff smaller, I use this patch to declare 'struct
>>sec_path *sp' only ifdef CONFIG_XFRM, what do you think ?  I also
>>use a patch to declare nfcache, nfctinfo and nfct only if
>>CONFIG_NETFILTER_CONNTRACK or CONFIG_NETFILTER_CONNTRACK_MODULE are
>>defined, but thats more intrusive.  Also, tc_index is not used if
>>CONFIG_NET_SCHED only is declared but none of CONFIG_NET_SCH_* In my
>>case, I am using CONFIG_NET_SCHED only to be able to do : tc -s -d
>>qdisc
>=20
>=20
> Distributions enable all of the ifdefs, and that is thus the
> size and resultant performance most users see.

Well, I had this idea because I found another similar use in include/linu=
x/ip.h

struct inet_sock {
     /* sk and pinet6 has to be the first two members of inet_sock */
     struct sock     sk;
#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
     struct ipv6_pinfo   *pinet6;
#endif


You are right such conditions are distributions nightmare :(

Eric
