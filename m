From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: Re: [PATCH] drivers/net: Use RCU_INIT_POINTER(x, NULL) in tun.c
Date: Mon, 24 Mar 2014 16:47:32 +0800
Message-ID: <532FF124.1030209@cn.fujitsu.com>
References: <1395599552-7486-1-git-send-email-monamagarwal123@gmail.com>	 <20140323194113.GA13633@redhat.com>	 <1395604457.9117.21.camel@edumazet-glaptop2.roam.corp.google.com>	 <20140323213349.GA8832@redhat.com>	 <20140323221256.GG4405@linux.vnet.ibm.com>	 <20140324050939.GB8832@redhat.com> <1395638727.9117.55.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Monam Agarwal <monamagarwal123@gmail.com>, davem@davemloft.net,
	jasowang@redhat.com, xemul@parallels.com, wuzhy@linux.vnet.ibm.com,
	therbert@google.com, yamato@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395638727.9117.55.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/24/2014 01:25 PM, Eric Dumazet wrote:
> On Mon, 2014-03-24 at 07:09 +0200, Michael S. Tsirkin wrote:
> 
>> Seems an incredibly strict requirement for something that just
>> silences a warning.
>> What exactly should I test?
>> I intended to just verify this produces same code as before
>> d322f45ceed525daa under a recent gcc.
> 
> Thats because many rcu_assign_pointer(X, NULL) were already converted to
> RCU_INIT_POINTER(X, NULL)
> 
> Quite frankly I don't know why you bother at all.
> 
> Adding back the lazy test in rcu_assign_pointer() doesn't help to make
> the API cleaner and easier to understand.
> 
> People are usually using RCU API without really understanding
> all the issues. They tend to add superfluous barriers because they feel
> better. 
> 
> Having separate RCU_INIT_POINTER() and rcu_assign_pointer() serve as
> better documentation of the code, I find it more easier to immediately
> check what is going on while reviewing stuff.
> 
> Presumably, checkpatch.pl could be augmented to suggest to use
> RCU_INIT_POINTER(X, NULL) instead of rcu_assign_pointer(X, NULL)


I prefer rcu_assign_pointer(X, NULL) than RCU_INIT_POINTER(X, NULL),
NULL should not be a special pointer value to the users of RCU.

the RCU implements should hide the difference if RCU implements
differentiate the values for optimization.

RCU_INIT_POINTER() sounds as an initialization-stage API. If we need
something different for NULL pointer, I prefer
rcu_assign_*null*_pointer().

rcu_assign_pointer(X, NULL) implies compiler barrier(), but
RCU_INIT_POINTER(X, NULL) doesn't.

> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
