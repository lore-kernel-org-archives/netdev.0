From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: =?UTF-8?B?UmU6IG5ldC9uZXRmaWx0ZXIvbmZfY29ubnRyYWNrX3Byb3RvX3RjcC4=?=
 =?UTF-8?B?YzoxNjA2Ojk6IGVycm9yOiDigJhzdHJ1Y3QgbmZfcHJvdG9fbmV04oCZIGhhcyA=?=
 =?UTF-8?B?bm8gbWVtYmVyIG5hbWVkIOKAmHVzZXLigJk=?=
Date: Wed, 13 Jun 2012 10:06:49 +0800
Message-ID: <4FD7F5B9.9040006@cn.fujitsu.com>
References: <4fd664de.oQN9NTKjdledtla0%wfg@linux.intel.com> <20120611221521.GA27239@1984> <20120611.152344.1072167705198124284.davem@davemloft.net> <20120612002655.GA28155@1984> <4FD69F5E.3060900@cn.fujitsu.com> <20120612092940.GB30080@1984> <4FD72203.9090005@cn.fujitsu.com> <20120612160304.GA31427@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, wfg@linux.intel.com,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:44745 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752673Ab2FMCGX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 22:06:23 -0400
In-Reply-To: <20120612160304.GA31427@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B406=E6=9C=8813=E6=97=A5 00:03, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> On Tue, Jun 12, 2012 at 07:03:31PM +0800, Gao feng wrote:
>> =E4=BA=8E 2012=E5=B9=B406=E6=9C=8812=E6=97=A5 17:29, Pablo Neira Ayu=
so =E5=86=99=E9=81=93:
>>
>>>> nf_proto_net.users has different meaning when SYSCTL enabled or di=
sabled.
>>>>
>>>> when SYSCTL enabled,it means if both tcpv4 and tcpv6 register the =
sysctl,
>>>> it is increased when register sysctl success and decreased when un=
register sysctl.
>>>> we can regard it as the refcnt of ctl_table.
>>>>
>>>> when SYSCTL disabled,it just used to identify if the proto's perne=
t data
>>>> has been initialized.
>>>
>>> We have to use two different counters for this. The conditional
>>> meaning of that variable is really confusing.
>>>
>> Hi David & Pablo
>>
>> Please have a look at this patch and tell me if it's OK.
>> it base on Pable's patch.
>=20
> I think we have to merge those tcpv4_init_net and tcpv6_init_net
> functions into one single function tcp_init_net. Then, we can pass
> l4proto->l3proto to init_net:
>=20
>         if (proto->init_net) {
>                 ret =3D proto->init_net(net, l4proto->l3proto);
>                 if (ret < 0)
>                         return ret;
>         }
>=20
> Thus, we can check if this is IPv4 or IPv6 and initialize the compat
> part accordingly.

Agree, it will be more clearer and will decrease the redundancy codes.

>=20
> Still, we have that pn->users thing:
>=20
>         if (!pn->users++) {
>                 for (i =3D 0; i < TCP_CONNTRACK_TIMEOUT_MAX; i++)
>                         tn->timeouts[i] =3D tcp_timeouts[i];
>=20
>                 tn->tcp_loose =3D nf_ct_tcp_loose;
>                 tn->tcp_be_liberal =3D nf_ct_tcp_be_liberal;
>                 tn->tcp_max_retrans =3D nf_ct_tcp_max_retrans;
>         }
>=20
> Define some pn->initialized boolean. Set it to true at the end of
> the new tcp_init_net.
>=20
> Similar thing for other protocol trackers.
>=20
> Let me know if you are going to send me patches. In that case, please
> do it on top of the current tree.

Ok,I will clean up it as you said.

>=20
> Once that has been cleaned up, we can prepare follow-up patches to
> move the sysctl code to nf_conntrack_proto_*_sysctl.c to reduce the
> ifdef pollution.
>=20
