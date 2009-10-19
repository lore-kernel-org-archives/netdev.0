From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: kernel panic in latest vanilla stable, while using nameif with
	"alive" pppoe interfaces
Date: Mon, 19 Oct 2009 23:29:10 +0400
Message-ID: <20091019192910.GC5233@lenovo>
References: <200910190002.39937.denys@visp.net.lb> <e6d1cecd0910182034t9d24859mc6f392875b36ad17@mail.gmail.com> <4ADC5D3B.8010006@gmail.com> <e6d1cecd0910190619t3e009e1by49cc8f7307eb7cdb@mail.gmail.com> <20091019155034.GA5233@lenovo> <e6d1cecd0910190905x382bfc23w2987c84aa0837609@mail.gmail.com> <4ADC9DE2.5010308@gmail.com> <e6d1cecd0910191107h899a4ffs588f2413093dfb4b@mail.gmail.com> <4ADCB3A4.8060408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Ostrowski <mostrows@gmail.com>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev <netdev@vger.kernel.org>, linux-ppp@vger.kernel.org,
	paulus@samba.org, mostrows@earthlink.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4ADCB3A4.8060408@gmail.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Eric Dumazet - Mon, Oct 19, 2009 at 08:44:52PM +0200]
...
| 
| Not really :)
| 
| I dont believe you should care of namespace, and/or mess with its refcount at all.
| 
| Please dont use maybe_get_net() : This function should not ever be used in drivers/net
| 
| You can add a BUG_ON(dev_net(xxxx)->count <= 0) if you really want, but if this
| assertion is false, this is not because of pppoe.
| 
...
| So pppoe_flush_dev() can run concurently and dev_put(po->ppoe_dev) at same time.
| 
| In fact pppoe_flush_dev() can change po->ppoe_dev anytime, so you should check
| all occurences of po->ppoe_dev use in the code and check if appropriate locking is done.
| 
| pppoe_rcv_core() is not safe
| pppoe_ioctl() is not safe
| pppoe_sendmsg() is not safe
| __pppoe_xmit() is not safe
| 

Sigh... seem so (which is mostly my fault not Michal). Every time we touch pppoe_dev we
should dev_hold on it and dev_put as only done all we need. Async nature
of notifier seem to be a key here.

	-- Cyrill
