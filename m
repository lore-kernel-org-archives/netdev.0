From: jovi zhang <bookjovi@gmail.com>
Subject: Re: [PATCH] netlink: Fix kfree NULL pointer
Date: Wed, 8 Sep 2010 13:33:28 +0800
Message-ID: <AANLkTim+=vj+k3=1hzT3=J4ssOopp5Eq=g+DHis=pZFN@mail.gmail.com>
References: <AANLkTikp0m8cQYfEBHP_E8XpGZqdMj6Cr4M=aWCnei=X@mail.gmail.com>
	<1283923185.2634.772.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes.berg@intel.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Dobriyan <adobriyan@openvz.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35649 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225Ab0IHFda convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 01:33:30 -0400
In-Reply-To: <1283923185.2634.772.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 8, 2010 at 1:19 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le mercredi 08 septembre 2010 =C3=A0 13:13 +0800, jovi zhang a =C3=A9=
crit :
>> It will kfree NULL pointer if listeners is NULL. fix it.
>>
>> Signed-off-by: bookjovi@gmail.com
>> net/netlink/af_netlink.c | =C2=A0 =C2=A05 +++--
>> 1 files changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
>> index 980fe4a..1c7bf48 100644
>> --- a/net/netlink/af_netlink.c
>> +++ b/net/netlink/af_netlink.c
>> @@ -1532,8 +1532,10 @@ netlink_kernel_create(struct net *net, int
>> unit, unsigned int groups,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (input)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nlk_sk(sk)->n=
etlink_rcv =3D input;
>>
>> - =C2=A0 =C2=A0 =C2=A0 if (netlink_insert(sk, net, 0))
>> + =C2=A0 =C2=A0 =C2=A0 if (netlink_insert(sk, net, 0)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kfree(listeners);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out_sock=
_release;
>> + =C2=A0 =C2=A0 =C2=A0 }
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0nlk =3D nlk_sk(sk);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0nlk->flags |=3D NETLINK_KERNEL_SOCKET;
>> @@ -1553,7 +1555,6 @@ netlink_kernel_create(struct net *net, int uni=
t,
>> unsigned int groups,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return sk;
>>
>> out_sock_release:
>> - =C2=A0 =C2=A0 =C2=A0 kfree(listeners);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0netlink_kernel_release(sk);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;
>
>
> This patch is not needed
>
> kfree(NULL) is legal
>
>
>
>

YES, maybe kfree(NULL) is legal, but I cannot see there have any need
to invoke kfree(NULL) in this function.
=C2=A0Also I check kfree usage in other code, I havn't find any kfree(N=
ULL) usage.
