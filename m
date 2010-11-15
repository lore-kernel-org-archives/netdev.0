From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] netfilter: place in source hash after SNAT is done
Date: Mon, 15 Nov 2010 19:16:46 +0800
Message-ID: <AANLkTi=ymap8-3ZJQ6OOSKNeQ9jrbUr7SwFNH9L3Nv7T@mail.gmail.com>
References: <1289796483-2970-1-git-send-email-xiaosuo@gmail.com> <4CE11475.30905@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:62766 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932255Ab0KOLRI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 06:17:08 -0500
In-Reply-To: <4CE11475.30905@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 15, 2010 at 7:07 PM, Patrick McHardy <kaber@trash.net> wrot=
e:
> On 15.11.2010 05:48, Changli Gao wrote:
>> If SNAT isn't done, the wrong info maybe got by the other cts.
>>
>> As the filter table is after DNAT table, the packets dropped in filt=
er
>> table also bother bysource hash table.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> ---
>> =A0net/ipv4/netfilter/nf_nat_core.c | =A0 18 +++++++++++-------
>> =A01 file changed, 11 insertions(+), 7 deletions(-)
>> diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/n=
f_nat_core.c
>> index c04787c..51ce55a 100644
>> --- a/net/ipv4/netfilter/nf_nat_core.c
>> +++ b/net/ipv4/netfilter/nf_nat_core.c
>> @@ -545,11 +550,10 @@ static void nf_nat_move_storage(void *new, voi=
d *old)
>> =A0 =A0 =A0 struct nf_conn_nat *old_nat =3D old;
>> =A0 =A0 =A0 struct nf_conn *ct =3D old_nat->ct;
>>
>> - =A0 =A0 if (!ct || !(ct->status & IPS_NAT_DONE_MASK))
>> + =A0 =A0 if (!ct || !(ct->status & IPS_SRC_NAT_DONE))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>>
>> =A0 =A0 =A0 spin_lock_bh(&nf_nat_lock);
>> - =A0 =A0 new_nat->ct =3D ct;
>
> Why are you removing this?
>

nf_ct_ext uses __krealloc() to enlarge memory, so the content has been
copied already.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
