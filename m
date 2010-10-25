From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 1/9] tproxy: split off ipv6 defragmentation to a separate
 module
Date: Mon, 25 Oct 2010 22:42:48 +0200
Message-ID: <4CC5EBC8.9000701@trash.net>
References: <20101021104709.5192.31249.stgit@este.odu>	 <20101021104709.5192.64336.stgit@este.odu>  <4CC02456.4050301@trash.net>	 <1287661385.13326.45.camel@este.odu>  <4CC0486D.60703@trash.net>	 <1287699558.2607.5.camel@edumazet-laptop>	 <1287999512.2160.25.camel@este.odu> <1288001640.2826.96.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: KOVACS Krisztian <hidden@balabit.hu>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Balazs Scheidler <bazsi@balabit.hu>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1288001640.2826.96.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 25.10.2010 12:14, schrieb Eric Dumazet:
> Le lundi 25 octobre 2010 =C3=A0 11:38 +0200, KOVACS Krisztian a =C3=A9=
crit :
>> Hi,
>>
>> On Fri, 2010-10-22 at 00:19 +0200, Eric Dumazet wrote:
>>> Le jeudi 21 octobre 2010 =C3=A0 16:04 +0200, Patrick McHardy a =C3=A9=
crit :
>>>> Am 21.10.2010 13:43, schrieb KOVACS Krisztian:
>>>>> tproxy: split off ipv6 defragmentation to a separate module
>>>>>    =20
>>>>>     Like with IPv4, TProxy needs IPv6 defragmentation but does no=
t
>>>>>     require connection tracking. Since defragmentation was couple=
d
>>>>>     with conntrack, I split off the two, creating an nf_defrag_ip=
v6 module,
>>>>>     similar to the already existing nf_defrag_ipv4.
>>>>
>>>> Applied, thanks.
>>>
>>> Hmm...
>>>
>>> CONFIG_IPV6=3Dm
>>> CONFIG_NETFILTER_TPROXY=3Dm
>>>
>>>
>>>   MODPOST 201 modules
>>> ERROR: "nf_defrag_ipv6_enable" [net/netfilter/xt_TPROXY.ko] undefin=
ed!
>>> ERROR: "ipv6_find_hdr" [net/netfilter/xt_TPROXY.ko] undefined!
>>>
>>> Sorry, it's late here, I wont fix this ;)
>>
>> Oops, I guess this is because you do have IPv6 support but don't hav=
e
>> ip6tables enabled in your config. Does the patch below fix the issue=
 for
>> you? (For me it now compiles with and without IPv6 conntrack, ip6tab=
les
>> and IPv6 support, too.)
>>
>>
>=20
> I had ip6tables enabled, but not CONFIG_NF_CONNTRACK_IPV6 ;)
>=20
>>
>> netfilter: fix module dependency issues with IPv6 defragmentation, i=
p6tables and xt_TPROXY
>>
>> One of the previous tproxy related patches split IPv6 defragmentatio=
n and
>> connection tracking, but did not correctly add Kconfig stanzas to ha=
ndle the
>> new dependencies correctly. This patch fixes that by making the conf=
ig options
>> mirror the setup we have for IPv4: a distinct config option for defr=
agmentation
>> that is automatically selected by both connection tracking and
>> xt_TPROXY/xt_socket.
>>
>> The patch also changes the #ifdefs enclosing IPv6 specific code in x=
t_socket
>> and xt_TPROXY: we only compile these in case we have ip6tables suppo=
rt enabled.
>>
>> Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>
>=20
> Reported-and-tested-by: Eric Dumazet <eric.dumazet@gmail.com>

Dave, please apply directly. Thanks!
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
