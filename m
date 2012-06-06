From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 01/15] netfilter: add namespace support for l4proto
Date: Wed, 06 Jun 2012 08:56:28 +0800
Message-ID: <4FCEAABC.1050807@cn.fujitsu.com>
References: <1338275063-11711-1-git-send-email-gaofeng@cn.fujitsu.com> <1338275063-11711-2-git-send-email-gaofeng@cn.fujitsu.com> <20120605235600.GB27222@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitus.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120605235600.GB27222@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi pablo
=E4=BA=8E 2012=E5=B9=B406=E6=9C=8806=E6=97=A5 07:56, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> On Tue, May 29, 2012 at 03:04:09PM +0800, Gao feng wrote:
>> From: Gao feng <gaofeng@cn.fujitus.com>
>>
>> struct nf_proto_net stroes proto's ctl_table_header and ctl_table,
>> nf_ct_l4proto_(un)register_sysctl use it to register sysctl.
>> because AF_INET6's protocols need not do compat, so register or
>> unregister sysctl when l4proto.l3proto !=3D AF_INET6.
>>
>> - the net_id field is used to store the pernet_operations id
>>   that belones to l4proto.
>>
>> - init_net will be used to initial the proto's pernet data
>>
>> - nf_ct_(un)register_sysctl are changed to support net namespace,
>>   use (un)register_net_sysctl_table replaces (un)register_sysctl_pat=
hs.
>>   and in nf_ct_unregister_sysctl,kfree table only when users is 0.
>>
>> - Add the struct net as param of nf_conntrack_l4proto_(un)register.
>>   register or unregister the l4proto only when the net is init_net.
>>
>> - nf_conntrack_l4proto_register call init_net to initial the pernet
>>   data of l4proto.
>>
>> - nf_ct_l4proto_net is used to get the pernet data of l4proto.
>>
>> - use init_net as a param of nf_conntrack_l4proto_(un)register.
>=20
> I have applied this patchset, but I had to rewrite the patch
> descriptions.
>=20
> I don't blame your English neither your writing abilities (I'm not
> native speaker and not that good at writing either) but I think you
> can make it better next time.

I apologize for my pool English and writing abilities.
Maybe I should take an english course...

>=20
> Basically, you don't need to comment every single change that the
> patch does. That's easy to see by looking at the patchset.
>=20
> Instead, just provide brief explanation on your intentions with the
> patch, clarify things that may look not obvious to the reviewer and
> what we'll get with this.

Got it, thanks for teaching me this. ;)

> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-d=
evel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
