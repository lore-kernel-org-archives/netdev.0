From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Thu, 16 Apr 2009 14:24:06 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0904161423240.22333@fbirervta.pbzchgretzou.qr>
References: <20090411174801.GG6822@linux.vnet.ibm.com> <18913.53699.544083.320542@cargo.ozlabs.ibm.com> <20090412173108.GO6822@linux.vnet.ibm.com> <20090412.181330.23529546.davem@davemloft.net> <20090413040413.GQ6822@linux.vnet.ibm.com> <20090413095309.631cf395@nehalam>
 <49E48136.5060700@trash.net> <49E49C65.8060808@cosmosbay.com> <20090414074554.7fa73e2f@nehalam> <49E4B0A5.70404@cosmosbay.com> <b6a2187b0904140951r3c6a41fdnc26b149202bdfa84@mail.gmail.com> <20090414111716.28585806@nehalam> <49E4E3E8.5090201@cosmosbay.com>
 <20090414141351.0f63ac98@nehalam> <49E502B5.7070700@cosmosbay.com> <49E5BDF7.8090502@trash.net> <20090415135526.2afc4d18@nehalam> <49E64C91.5020708@cosmosbay.com> <alpine.LSU.2.00.0904152354330.5844@fbirervta.pbzchgretzou.qr> <49E720BE.2000200@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jeff Chua <jeff.chua.linux@gmail.com>,
	paulmck@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	paulus@samba.org, mingo@elte.hu, torvalds@linux-foundation.org,
	laijs@cn.fujitsu.com, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49E720BE.2000200@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thursday 2009-04-16 14:12, Patrick McHardy wrote:
> Jan Engelhardt wrote:
>> On Wednesday 2009-04-15 23:07, Eric Dumazet wrote:
>>> Stephen Hemminger a =C3=A9crit :
>>>> Looks like there is some recursive path into ip_tables that makes =
the
>>>> per-cpu spinlock break.  I get lockup's with KVM networking.
>>>>
>>>> Suggestions?
>>> Well, it seems original patch was not so bad after all
>>>
>>> http://lists.netfilter.org/pipermail/netfilter-devel/2006-January/0=
23175.html
>>>
>>> So change per-cpu spinlocks to per-cpu rwlocks=20
>>> and use read_lock() in ipt_do_table() to allow recursion...
>>>
>> iptables cannot quite recurse into itself due to the comefrom stuff.
>
> Actually it can by using the REJECT target:

Yes, but it has to return an absolute verdict (which REJECT does),
so it's not really a recursion, it's more like a goto without return.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
