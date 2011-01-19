From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH resend] netfilter: place in source hash after SNAT is done
Date: Wed, 19 Jan 2011 08:03:48 +0800
Message-ID: <AANLkTimPEaXiiFiyD7Anvg+x5zJUsF04P_yPbj8KzYaF@mail.gmail.com>
References: <1295090930-16671-1-git-send-email-xiaosuo@gmail.com> <4D35A0F2.5010908@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D35A0F2.5010908@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 18, 2011 at 10:17 PM, Patrick McHardy <kaber@trash.net> wro=
te:
>> =A0net/ipv4/netfilter/nf_nat_core.c | =A0 18 +++++++++++-------
>> =A01 file changed, 11 insertions(+), 7 deletions(-)
>> diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/n=
f_nat_core.c
>> index c04787c..51ce55a 100644
>> --- a/net/ipv4/netfilter/nf_nat_core.c
>> +++ b/net/ipv4/netfilter/nf_nat_core.c
>> @@ -221,7 +221,14 @@ get_unique_tuple(struct nf_conntrack_tuple *tup=
le,
>> =A0 =A0 =A0 =A0 =A0manips not an issue. =A0*/
>> =A0 =A0 =A0 if (maniptype =3D=3D IP_NAT_MANIP_SRC &&
>> =A0 =A0 =A0 =A0 =A0 !(range->flags & IP_NAT_RANGE_PROTO_RANDOM)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (find_appropriate_src(net, zone, orig_t=
uple, tuple, range)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* try the original tuple first */
>
> This doesn't seem to be related to the hashing change. Please describ=
e
> the intention behind this change.

Currently, we add the ct at the head of the corresponding bucket of
the source hash table after DNAT is done, so when we do SNAT, the
original ct will be tried first. This change is used to keep this
behavior.


>
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (in_range(orig_tuple, range)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!nf_nat_used_tuple(ori=
g_tuple, ct)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *tuple =3D=
 *orig_tuple;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 } else if (find_appropriate_src(net, zone,=
 orig_tuple, tuple,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0range)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("get_unique_tup=
le: Found current src map\n");
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!nf_nat_used_tuple(t=
uple, ct))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>
>
>



--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
