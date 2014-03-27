From: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: re: rsi: Add RS9113 wireless driver
Date: Thu, 27 Mar 2014 18:05:01 +0300
Message-ID: <20140327150501.GA1633@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fariya Fatima <fariyaf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: fariyaf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Fariya Fatima,

The patch dad0d04fa7ba: "rsi: Add RS9113 wireless driver" from Mar
16, 2014, leads to the following static checker warning:

	drivers/net/wireless/rsi/rsi_91x_mgmt.c:751 rsi_load_bootup_params()
	warn: signedness bug returning '(-12)'

drivers/net/wireless/rsi/rsi_91x_mgmt.c
   741  static u8 rsi_load_bootup_params(struct rsi_common *common)
   742  {
   743          struct sk_buff *skb;
   744          struct rsi_boot_params *boot_params;
   745  
   746          rsi_dbg(MGMT_TX_ZONE, "%s: Sending boot params frame\n", __func__);
   747          skb = dev_alloc_skb(sizeof(struct rsi_boot_params));
   748          if (!skb) {
   749                  rsi_dbg(ERR_ZONE, "%s: Failed in allocation of skb\n",
   750                          __func__);
   751                  return -ENOMEM;
                               ^^^^^^^
This doesn't matter because the caller doesn't progate the error code
anyway.  Please fix that as well.

	ret = rsi_load_bootup_params(...);
	if (ret)
		return ret;

Instead of:
	if (rsi_load_bootup_params(...))
		erturn -ENOMEM;

   752          }

regards,
dan carpenter
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
