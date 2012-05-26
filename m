From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 01/17] netfilter: add struct nf_proto_net for register
 l4proto sysctl
Date: Sat, 26 May 2012 10:28:33 +0800
Message-ID: <4FC03FD1.2050408@cn.fujitsu.com>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com> <1336985547-31960-2-git-send-email-gaofeng@cn.fujitsu.com> <20120523101200.GA2836@1984> <4FBD9076.6060309@cn.fujitsu.com> <20120524095859.GC13091@1984> <4FBE1372.60206@cn.fujitsu.com> <20120524143854.GA15898@1984> <4FBEDADE.8040905@cn.fujitsu.com> <20120525025451.GA21076@1984> <4FBF207D.80809@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitus.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4FBF207D.80809@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B405=E6=9C=8825=E6=97=A5 14:02, Gao feng =E5=86=99=
=E9=81=93:
> =E4=BA=8E 2012=E5=B9=B405=E6=9C=8825=E6=97=A5 10:54, Pablo Neira Ayus=
o =E5=86=99=E9=81=93:
>> On Fri, May 25, 2012 at 09:05:34AM +0800, Gao feng wrote:
>>> =E4=BA=8E 2012=E5=B9=B405=E6=9C=8824=E6=97=A5 22:38, Pablo Neira Ay=
uso =E5=86=99=E9=81=93:
>>>> On Thu, May 24, 2012 at 06:54:42PM +0800, Gao feng wrote:
>>>> [...]
>>>>>>>> I don't see why we need this new field.
>>>>>>>>
>>>>>>>> It seems to be set to 1 in each structure that has set:
>>>>>>>>
>>>>>>>> .ctl_compat_table
>>>>>>>>
>>>>>>>> to non-NULL. So, it's redundant.
>>>>>>>>
>>>>>>>> Moreover, you already know from the protocol tracker itself if=
 you
>>>>>>>> have to allocate the compat ctl table or not.
>>>>>>>>
>>>>>>>> In other words: You set compat to 1 for nf_conntrack_l4proto_g=
eneric.
>>>>>>>> Then, you pass that compat value to generic_init_net via ->ine=
t_net
>>>>>>>> again, but this information (that determines if the compat has=
 to be
>>>>>>>> done or not) is already in the scope of the protocol tracker.
>>>>>>>>
>>>>>>>
>>>>>>> because some protocols such l4proto_tcp6 and l4proto_tcp use th=
e same init_net
>>>>>>> function. the l4proto_tcp6 doesn't need compat sysctl, so we sh=
ould use this new
>>>>>>> field to identify if we should kmemdup compat_sysctl_table.
>>>>>>
>>>>>> Then, could you use two init_net functions? one for TCP for IPv4=
 and another
>>>>>> for TCP for IPv6?
>>>>>
>>>>> Of cause, if you prefer to impletment it in this way.
>>>>
>>>> If this removes the .compat field that you added, then use two
>>>> init_net functions, yes.
>>>
>>> Sorry I miss something.
>>>
>>> nf_ct_l4proto_unregister_sysctl also uses .compat to identify if we
>>> can unregister the compat sysctl.
>>>
>>> if we register l4proto_tcp and l4proto_tcp6 both. without .compat,
>>> when unregister l4proto_tcp6, the compat sysctl will be unregister =
too.
>>>
>>> So maybe we have to use .compat.
>>
>> Could you resolve this by checking pn->ctl_compat_header !=3D NULL ?
>=20
> pn->ctl_table_header and ctl_compat_header is shared by l4proto_tcp a=
nd l4proto_tcp6.
> if we both register l4proto_tcp and l4proto_tcp6, when unregister l4p=
roto_tcp6
> pn->ctl_compat_header must not be NULL.
>=20

Maybe we can resolve this by  nf_conntrack_l4proto.l3proto =3D=3D AF_IN=
ET &&  pn->ctl_compat_header !=3D NULL
Because compat sysctl is registered by AF_INET's proto only.

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
