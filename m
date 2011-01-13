From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: ipt_CLUSTERIP: dont flood with "no conntrack!"
Date: Thu, 13 Jan 2011 12:54:51 +0100
Message-ID: <4D2EE80B.6010707@netfilter.org>
References: <4D2E1A74.5080102@netfilter.org>	 <1294917210.3570.48.camel@edumazet-laptop> <4D2EE09A.1010409@netfilter.org> <1294918365.3570.56.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52704 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756566Ab1AMLyz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jan 2011 06:54:55 -0500
In-Reply-To: <1294918365.3570.56.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/01/11 12:32, Eric Dumazet wrote:
> Le jeudi 13 janvier 2011 =C3=A0 12:23 +0100, Pablo Neira Ayuso a =C3=A9=
crit :
>> Hi Eric,
>>
>> On 13/01/11 12:13, Eric Dumazet wrote:
>>> ipt_CLUSTERIP users might hit this annoying printk, if they forgot =
an
>>> "iptables -I INPUT -m state --state INVALID -j DROP" before CLUSTER=
IP
>>> rule. We could use net_ratelimit() here, or not log the message at =
all.
>>> I chose to log it once per config.
>>
>> I think that this should be converted to pr_debug() instead, there's
>> also another reference to "unknown protocol" that should be converte=
d as
>> well.
>=20
> Problem is pr_debug() is a noop most of the time,
> and printk(KERN_DEBUG is a bit ugly ...
>=20
> If we print the message once, better to really print it ;)

But printing this does not provide any useful information. The first
packet that does not belong to the cluster node that has received the
packet, or the first invalid packet, will trigger this.

Moreover, this confuses users since they can do nothing if they receive
this message.

Moreover, this target should be supersedes by the cluster match, which
has been there for quite some time (it's also more flexible).
