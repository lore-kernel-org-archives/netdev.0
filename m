From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: kernel panic in latest vanilla stable, while using nameif with
	"alive" pppoe interfaces
Date: Tue, 20 Oct 2009 09:17:59 +0400
Message-ID: <aa79d98a0910192217x2a9bb142r114ae2fa633e3bd2@mail.gmail.com>
References: <200910190002.39937.denys@visp.net.lb>
	 <20091019155034.GA5233@lenovo>
	 <e6d1cecd0910190905x382bfc23w2987c84aa0837609@mail.gmail.com>
	 <4ADC9DE2.5010308@gmail.com>
	 <e6d1cecd0910191107h899a4ffs588f2413093dfb4b@mail.gmail.com>
	 <4ADCB3A4.8060408@gmail.com>
	 <e6d1cecd0910191354o16d023d2lbe2761a97e88acea@mail.gmail.com>
	 <4ADD31A2.4030702@gmail.com>
	 <aa79d98a0910192202j4ea9f189g2ff719d57aa5a5eb@mail.gmail.com>
	 <4ADD4518.8020909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal Ostrowski <mostrows@gmail.com>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev <netdev@vger.kernel.org>, linux-ppp@vger.kernel.org,
	paulus@samba.org, mostrows@earthlink.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <4ADD4518.8020909@gmail.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/20/09, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Cyrill Gorcunov a =E9crit :
>> On 10/20/09, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> Michal Ostrowski a =E9crit :
>>>> Access of po->pppoe_dev is guarded by sk->sk_state & PPPOX_CONNECT=
ED,
>>>> and all use cases now rely on the socket lock.  Because of this, t=
he
>>>> ref-count on the namespace held by the socket object suffices to h=
old
>>>> the namespace in existence and so we don't need to ref-count the
>>>> namespace in PPPoE. The flush_lock is gone.
>>>>
>>> Seems good !
>>>
>>> But can we use lock_sock() in __pppoe_xmit() context ?
>>>
>>
>> Eric, most probably i miss something, but how lock sock protect us
>> from mtu changed via sysfs. This action calls change mtu notifier
>> which doesn't care about sockets at all...
>
> This ultimately calls pppoe_flush_dev() and this function
> takes care of taking appropriate sock_locks() on each sockets ?
>
This hold and lock socks but set pppoe_dev to null as well. I'll back
later. And i need to reread the code.
