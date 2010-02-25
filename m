From: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [net-next-2.6 PATCH] infiniband: convert to use
	netdev_for_each_mc_addr
Date: Thu, 25 Feb 2010 09:49:15 +0100
Message-ID: <20100225084915.GA3171@psychotron.redhat.com>
References: <20100224151108.GD2663@psychotron.lab.eng.brq.redhat.com>
 <4B862E07.7020002@Voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Or Gerlitz <ogerlitz-smomgflXvOZWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B862E07.7020002-hKgKHo2Ms0FWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thu, Feb 25, 2010 at 09:00:07AM CET, ogerlitz-smomgflXvOZWk0Htik3J/w@public.gmane.org wrote:
>Jiri Pirko wrote:
>> --- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
>> +++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
>> @@ -767,11 +767,8 @@ void ipoib_mcast_dev_flush(struct net_device *dev)
>> -static int ipoib_mcast_addr_is_valid(const u8 *addr, unsigned int addrlen,
>> -				     const u8 *broadcast)
>> +static int ipoib_mcast_addr_is_valid(const u8 *addr, const u8 *broadcast)
>>  {
>> -	if (addrlen != INFINIBAND_ALEN)
>> -		return 0;
>
>This check was added by commit 5e47596b "IPoIB: Check multicast address format", may I ask what is the reason for removing it now?

Yes, at this very moment the check is not needless but it will be in a brief
future. dev_mc_add will look very similar like dev_unicast_add. But ok. Here's
patch adding the check in dev_mc_add right now to correct this state. Thanks Or.

Subject: [net-next-2.6 PATCH] net: add addr len check to dev_mc_add

Signed-off-by: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
index 9e2fa39..fd91569 100644
--- a/net/core/dev_mcast.c
+++ b/net/core/dev_mcast.c
@@ -96,6 +96,8 @@ int dev_mc_add(struct net_device *dev, void *addr, int alen, int glbl)
 	int err;
 
 	netif_addr_lock_bh(dev);
+	if (alen != dev->addr_len)
+		return -EINVAL;
 	err = __dev_addr_add(&dev->mc_list, &dev->mc_count, addr, alen, glbl);
 	if (!err)
 		__dev_set_rx_mode(dev);
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
