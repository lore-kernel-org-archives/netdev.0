From: Patrick McHardy <kaber@trash.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Mon, 16 Mar 2009 15:40:29 +0100
Message-ID: <49BE64DD.5030404@trash.net>
References: <20090310151357.GA10658@ioremap.net> <Pine.LNX.4.64.0903102147480.21593@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>, hawk@comx.dk
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0903102147480.21593@ask.diku.dk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesper Dangaard Brouer wrote:
> On Tue, 10 Mar 2009, Evgeniy Polyakov wrote:
> 
>> +            call_rcu(&f->rcu_head, ipt_osf_finger_free_rcu);
>> +        }
>> +    }
>> +    rcu_read_unlock();
> 
> Should the list_del_rcu() not be protected by a spinlock?
> 
> 
>> +    rcu_barrier();
> 
> In some of my code I call synchronize_net(), is it enough to call 
> rcu_barrier()?
> 
> What is the difference between:
> 
>  synchronize_rcu()
>  synchronize_net()
>  rcu_barrier()

synchronize_net() is just a call to synchronize_rcu(), so their
functionality is equivalent. synchronize_net() is however only
supposed to synchronize with RX packet processing, which is usually
not enough for netfilter. So I prefer synchronize_rcu() for clarity.
