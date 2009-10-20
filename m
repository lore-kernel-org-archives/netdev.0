From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: kernel panic in latest vanilla stable, while using nameif with
	"alive" pppoe interfaces
Date: Tue, 20 Oct 2009 10:04:29 +0400
Message-ID: <aa79d98a0910192304x162dec28o306afc18eb427125@mail.gmail.com>
References: <200910190002.39937.denys@visp.net.lb>
	 <e6d1cecd0910190905x382bfc23w2987c84aa0837609@mail.gmail.com>
	 <4ADC9DE2.5010308@gmail.com>
	 <e6d1cecd0910191107h899a4ffs588f2413093dfb4b@mail.gmail.com>
	 <4ADCB3A4.8060408@gmail.com>
	 <e6d1cecd0910191354o16d023d2lbe2761a97e88acea@mail.gmail.com>
	 <4ADD31A2.4030702@gmail.com>
	 <aa79d98a0910192202j4ea9f189g2ff719d57aa5a5eb@mail.gmail.com>
	 <4ADD4518.8020909@gmail.com>
	 <aa79d98a0910192217x2a9bb142r114ae2fa633e3bd2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Michal Ostrowski <mostrows@gmail.com>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev <netdev@vger.kernel.org>, linux-ppp@vger.kernel.org,
	paulus@samba.org, mostrows@earthlink.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <aa79d98a0910192217x2a9bb142r114ae2fa633e3bd2@mail.gmail.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/20/09, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> On 10/20/09, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>
>> This ultimately calls pppoe_flush_dev() and this function
>> takes care of taking appropriate sock_locks() on each sockets ?
>>
> This hold and lock socks but set pppoe_dev to null as well. I'll back
> later. And i need to reread the code.
>
from a second glance we have a race with pppoe_connect (err_put label)
and pppoe_flush_dev. Connect lock socket but while flushing we may
dev_put with null device. So as Eric pointed early the error path is
racy and should be protected with flush_lock.  Note that while
flushing pppoe we may do dev_put without socket locked. This should be
the corner case. Michal could you add this lock in pppoe_connect (i
cant do this at moment).
