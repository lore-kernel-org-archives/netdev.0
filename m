From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 2/2] netpoll: avoid reference leaks
Date: Mon, 07 Jul 2014 19:35:05 -0700 (PDT)
Message-ID: <20140707.193505.345276817146527821.davem@davemloft.net>
References: <0f692012238337f2c40893319830ae042523ce18.1404172155.git.decot@googlers.com>
	<cover.1404172155.git.decot@googlers.com>
	<f98ccbfee35a7ab7f9499ede9b34e6b1120d88f1.1404172155.git.decot@googlers.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, edumazet@google.com, amwang@redhat.com,
	antonio@meshcoding.com, jpirko@redhat.com
To: decot@googlers.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f98ccbfee35a7ab7f9499ede9b34e6b1120d88f1.1404172155.git.decot@googlers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>
Date: Mon, 30 Jun 2014 16:50:10 -0700

> This ensures that the ndo_netpoll_cleanup callback is called for every
> device that provides one. Otherwise there is a risk of reference leak
> with bonding for example, which depends on this callback to cleanup
> the slaves' references to netpoll info.
> 
> Tested:
>   see patch "netpoll: fix use after free"
> 
> Signed-off-by: David Decotigny <decot@googlers.com>

I definitely don't understand this.

Why would we call the cleanup function of an object before it's
reference count hits zero?  It is exactly the act of reaching a
zero refcount which should trigger invoking the cleanup callback.

If a refcount is being released in another location without checking
if it hits zero and invoking the cleanup if so, _THAT_ is the bug.
