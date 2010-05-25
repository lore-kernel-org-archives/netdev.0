From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH RFC] netfilter: iptables target SYNPROXY
Date: Tue, 25 May 2010 22:42:10 +0800
Message-ID: <AANLkTilbZ4PE7c6pep4bYvAx7ydx78qb4tKJi0vCjD52@mail.gmail.com>
References: <1274771218-3204-1-git-send-email-xiaosuo@gmail.com>
	<alpine.DEB.2.00.1005251353370.20667@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1005251353370.20667@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 25, 2010 at 8:17 PM, Jozsef Kadlecsik
<kadlec@blackhole.kfki.hu> wrote:
> Hi,
>
> On Tue, 25 May 2010, Changli Gao wrote:
>
>> iptables target SYNPROXY.
>>
>> This patch implements an iptables target SYNPROXY, which works in th=
e raw table
>> of the PREROUTING chain, before conntracking system. Syncookies is u=
sed, so no
>> new state is introduced into the conntracking system. In fact, until=
 the first
>> connection is established, conntracking system doesn't see any packe=
ts. So when
>> there is a SYN-flood attack, conntracking system won't be busy on fi=
nding and
>> deleting the un-assured ct.
>
> My main problem with your target is that by using it, important and u=
seful
> TCP options are lost: timestamp and SACK. That pushes back TCP by alm=
ost
> twenty years.

Yea. Only MSS option is  supported. But it is better than being DoSed.
And you can set a threshold for SYNPROXY with limit match, then there
isn't any difference if there isn't any SYN-flood attack.

>
> Here you reason for the target that it protects conntrack itself, but=
 in
> the Kconfig text you write that it protects the servers behind the
> firewall. Both can be true, but if the real goal is to defend the ser=
vers
> then your target could simply send a faked ACK to complete the three =
way
> handshake and that way TCP would not be crippled (conntrack timeout
> should still be adjusted).
>

Yes, both can be true. You descried above is called SYNDefender by
Checkpoint, and it doesn't work as well as SYNPROXY.

http://www.usenix.org/events/sec01/invitedtalks/oliver.pdf

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
