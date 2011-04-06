From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: fedora 14 kernel performance with ip forwarding workload
Date: Wed, 06 Apr 2011 22:18:56 +0200
Message-ID: <1302121136.2701.16.camel@edumazet-laptop>
References: <BANLkTikZfp_GLyNRufAzqv3Yeb5d12BPDA@mail.gmail.com>
	 <20110406.121208.189703414.davem@davemloft.net>
	 <20110406195719.GE14697@ghostprotocols.net>
	 <20110406.130239.232756965.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: acme@ghostprotocols.net, jesse.brandeburg@gmail.com,
	fedora-kernel-list@redhat.com, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42508 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049Ab1DFUTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 16:19:02 -0400
Received: by wya21 with SMTP id 21so1642997wya.19
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2011 13:19:01 -0700 (PDT)
In-Reply-To: <20110406.130239.232756965.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 06 avril 2011 =C3=A0 13:02 -0700, David Miller a =C3=A9crit=
 :
> From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
> Date: Wed, 6 Apr 2011 16:57:19 -0300
>=20
> > Something like ftrace code changing when the user inserts the first
> > rule?
> >=20
> > People wanting top performance disable it in the build, but thos wa=
nting
> > to stick to vendor provided kernels don't have that choice :)
>=20
> Using ftrace-like stubs would be an interesting idea, and I highly en=
courage
> people to work on something like that.
>=20
> However I want to reiterate that I think that real rules are installe=
d
> in Jesse's case, and once he removes those the majority of the
> overhead will disappear.  The FC14 workstation I'm using right now, o=
n
> which I've made no modifications to the installer's netfilter setting=
s,
> has the following rules:
>=20
> --------------------
> [root@ilbolle davem]# iptables -L
> Chain INPUT (policy ACCEPT)
> target     prot opt source               destination        =20
> ACCEPT     all  --  anywhere             anywhere            state RE=
LATED,ESTABLISHED=20
> ACCEPT     icmp --  anywhere             anywhere           =20
> ACCEPT     all  --  anywhere             anywhere           =20
> ACCEPT     tcp  --  anywhere             anywhere            state NE=
W tcp dpt:ssh=20
> ACCEPT     udp  --  anywhere             anywhere            state NE=
W udp dpt:ipp=20
> ACCEPT     udp  --  anywhere             224.0.0.251         state NE=
W udp dpt:mdns=20
> ACCEPT     tcp  --  anywhere             anywhere            state NE=
W tcp dpt:ipp=20
> ACCEPT     udp  --  anywhere             anywhere            state NE=
W udp dpt:ipp=20
> REJECT     all  --  anywhere             anywhere            reject-w=
ith icmp-host-prohibited=20
>=20
> Chain FORWARD (policy ACCEPT)
> target     prot opt source               destination        =20
> REJECT     all  --  anywhere             anywhere            reject-w=
ith icmp-host-prohibited=20
>=20
> Chain OUTPUT (policy ACCEPT)
> target     prot opt source               destination        =20
> [root@ilbolle davem]#=20
> --------------------
>=20
> I suspect Jesse has something similar on his test box.
>=20

I suspect problem is worse than that.

I remember last time I work on a fedora kernel, it had conntrack enable=
d

And yes, conntrack can really slowdown a router, because of default
parameters.

cat /proc/sys/net/nf_conntrack_max



