From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] xt_quota: don't copy quota back to userspace
Date: Fri, 23 Jul 2010 14:03:21 +0200
Message-ID: <4C498509.4010805@trash.net>
References: <1279860845-7177-1-git-send-email-xiaosuo@gmail.com>	 <alpine.LSU.2.01.1007230818260.815@obet.zrqbmnf.qr> <1279866523.2482.78.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1279866523.2482.78.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23.07.2010 08:28, Eric Dumazet wrote:
> Le vendredi 23 juillet 2010 =E0 08:20 +0200, Jan Engelhardt a =E9crit=
 :
>> On Friday 2010-07-23 06:54, Changli Gao wrote:
>>
>>> This patch should be applied after my another patch:
>>> http://patchwork.ozlabs.org/patch/59729/
>>>
>>> xt_quota: don't copy quota back to userspace
>>>
>>> In nowadays, table entries are per-cpu variables, so it don't make =
any=20
>>> sense to copy quota back to one of the variable instances. To keep=20
>>> things simple, this patch undo the copy.
>>
>> I object. This line is on purpose, to give at least a chance of=20
>> reporting back a more-or-less believable value. Without copying
>> the value back, users have moaned about the counter not decreasing
>> _at all_.
>=20
> Maybe, but current situation is buggy.

Indeed, besides not being able to properly "iptables-save" a rule,
its not possible to delete a specific quota rule since they can't
be distinguished based on the specified quota value:

# iptables -A INPUT -m quota --quota 1000
# iptables -A INPUT -m quota --quota 2000
# iptables -D INPUT -m quota --quota 2000
# iptables -vxnL INPUT
Chain INPUT (policy ACCEPT 2 packets, 96 bytes)
    pkts      bytes target     prot opt in     out     source
    destination
       6      356            all  --  *      *       0.0.0.0/0
  0.0.0.0/0           quota: 1644 bytes

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
