From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch] net: kill an RCU warning in inet_fill_link_af()
Date: Thu, 02 Dec 2010 11:14:02 +0800
Message-ID: <4CF70EFA.2070504@redhat.com>
References: <1291202063-6239-1-git-send-email-amwang@redhat.com> <1291219386.2856.924.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@infradead.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291219386.2856.924.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/02/10 00:03, Eric Dumazet wrote:
> Le mercredi 01 d=C3=A9cembre 2010 =C3=A0 19:14 +0800, Amerigo Wang a =
=C3=A9crit :
>> From: WANG Cong<amwang@redhat.com>
>>
>> The latest net-next-2.6 triggers an RCU warning during boot,
>> lockdep complains that in inet_fill_link_af() we call rcu_dereferenc=
e_check()
>> without rcu_read_lock() protection.
>>
>> This patch fixes it by replacing __in_dev_get_rcu() with in_dev_get(=
).
>
> Here is a better version, thanks a lot for your report and initial
> patch.
>
>
> [PATCH net-next-2.6] net: kill an RCU warning in inet_fill_link_af()
>
> commits 9f0f7272 (ipv4: AF_INET link address family) and cf7afbfeb8c
> (rtnl: make link af-specific updates atomic) used incorrect
> __in_dev_get_rcu() in RTNL protected contexts, triggering PROVE_RCU
> warnings.
>
> Switch to __in_dev_get_rtnl(), wich is more appropriate, since we hol=
d
> RTNL.
>
> Based on a report and initial patch from Amerigo Wang.
>

Alright, thanks for fixing it.

Reviewed-by: WANG Cong <amwang@redhat.com>
