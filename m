From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH V1 net-next] IB/ipoib: Fix ndo_get_iflink
Date: Mon, 20 Apr 2015 11:16:34 +0300
Message-ID: <5534B5E2.6060804@mellanox.com>
References: <1429191274-11600-1-git-send-email-erezsh@mellanox.com>
 <20150417.152133.1818018053733533978.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150417.152133.1818018053733533978.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 17/04/2015 22:21, David Miller wrote:
> From: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Date: Thu, 16 Apr 2015 16:34:34 +0300
> 
>> Currently, iflink of the parent interface was always accessed, even 
>> when interface didn't have a parent and hence we crashed there.
>>
>> Handle the interface types properly: for a child interface, return
>> the ifindex of the parent, for parent interface, return its ifindex.
>>
>> For child devices, make sure to set the parent pointer prior to
>> invoking register_netdevice(), this allows the new ndo to be called
>> by the stack immediately after the child device is registered.
>>
>> Fixes: 5aa7add8f14b ('infiniband/ipoib: implement ndo_get_iflink')
>> Reported-by: Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>> Signed-off-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>> Signed-off-by: Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> 
> Applied, thanks.

Doug, Roland,

You might want to include this patch in your for-next / for-4.1 trees,
or merge net-next again. Currently they contain the issue it fixes, and
it can prevent some systems with IPoIB from booting.

Regards,
Haggai

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
