From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH] net: add a synchronize_net() in netdev_rx_handler_unregister()
Date: Fri, 29 Mar 2013 16:11:32 +0100
Message-ID: <5155AF24.3090305@redhat.com>
References: <1364490997.6345.237.camel@gandalf.local.home>  <1364491792.15753.47.camel@edumazet-glaptop>  <20130329094856.GB1677@minipsycho.orion> <1364562082.5113.16.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Guy Streeter <streeter@redhat.com>,
	"Paul E. McKenney" <paulmck@us.ibm.com>, stephen@networkplumber.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364562082.5113.16.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/29/2013 02:01 PM, Eric Dumazet wrote:
>> CPU0 will see rx_handler set and yet, rx_handler_data nulled. Write
>> >barrier in rcu_assign_pointer() might prevent this reorder from happening.
>> >Therefore I suggest:
>> >
>> >diff --git a/net/core/dev.c b/net/core/dev.c
>> >index 0caa38e..c16b829 100644
>> >--- a/net/core/dev.c
>> >+++ b/net/core/dev.c
>> >@@ -3332,8 +3332,8 @@ void netdev_rx_handler_unregister(struct net_device *dev)
>> >  {
>> >
>> >  	ASSERT_RTNL();
>> >-	RCU_INIT_POINTER(dev->rx_handler, NULL);
>> >-	RCU_INIT_POINTER(dev->rx_handler_data, NULL);
>> >+	rcu_assign_pointer(dev->rx_handler, NULL);
>> >+	rcu_assign_pointer(dev->rx_handler_data, NULL);
>> >  }
>> >  EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
>> >
>> >
> Nope this changes nothing at all.
Erik, why doesn't help the write barrier between the assignments. It 
should guarantee their orders... or not?

Thanks,
Ivan
