From: Jay Vosburgh <jay.vosburgh-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH] bonding: move ipoib_header_ops to vmlinux
Date: Tue, 25 Nov 2014 10:41:17 -0800
Message-ID: <19740.1416940877@famine>
References: <1416893768-21369-1-git-send-email-wen.gang.wang@oracle.com> <20141125.010741.450666241983239119.davem@davemloft.net> <54742D6E.9030605@mellanox.com>
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <54742D6E.9030605-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:

>On 11/25/2014 8:07 AM, David Miller wrote:
>> IPOIB should not work over bonding as it requires that the device
>> use ARPHRD_ETHER.
>
>Hi Dave,
>
>IPoIB devices can be enslaved to both bonding and teaming in their HA mode,
>the bond device type becomes ARPHRD_INFINIBAND when this happens.

	The point was that pktgen disallows ARPHRD_INFINIBAND, not that
bonding does.

	Pktgen specifically checks for type != ARPHRD_ETHER, so the
IPoIB bond should not be able to be used with pkgten.  My suspicion is
that pktgen is being configured on the bond first, then an IPoIB slave
is added to the bond; this would change its type in a way that pktgen
wouldn't notice.

	-J

---
	-Jay Vosburgh, jay.vosburgh-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
