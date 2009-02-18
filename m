From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFT 3/4] Use mod_timer_noact to remove nf_conntrack_lock
Date: Wed, 18 Feb 2009 15:22:54 +0100
Message-ID: <499C19BE.7090407@cosmosbay.com>
References: <20090218051906.174295181@vyatta.com> <20090218052747.555811553@vyatta.com> <499C14AF.60704@cosmosbay.com> <499C155B.9010200@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	tglx@linutronix.de, netfilter-devel@vger.kernel.org,
	Martin Josefsson <gandalf@wlug.westbo.se>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <499C155B.9010200@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy a =E9crit :
> Eric Dumazet wrote:
>> Unfortunatly, this patch changes nothing, as most of the time, do_ac=
ct
>> is true.
>>
>> We also need to fine lock the accounting part as well.
>>
>>     spin_lock_bh(&ct->some_lock);
>>     acct =3D nf_conn_acct_find(ct);
>>     if (acct) {
>>         acct[CTINFO2DIR(ctinfo)].packets++;
>>         acct[CTINFO2DIR(ctinfo)].bytes +=3D
>>             skb->len - skb_network_offset(skb);
>>     }
>>     spin_unlock_bh(&ct->some_lock);
>>
>=20
> Its currently still enabled by default, but we intend to change that.
> After that I guess almost nobody will have it enabled.
>=20
>=20

Really ? I find this accounting stuff really useful and always enable i=
t :)


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
