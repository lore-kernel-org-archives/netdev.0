From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] r8152: use mutex for hw settings
Date: Thu, 09 Oct 2014 19:05:17 -0400 (EDT)
Message-ID: <20141009.190517.1411360749517857554.davem@davemloft.net>
References: <1394712342-15778-58-Taiwan-albertk@realtek.com>
	<20141008.154513.1944594723904521723.davem@davemloft.net>
	<0835B3720019904CB8F7AA43166CEEB2EC397B@RTITMBSTEMP01.realtek.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2EC397B-DsoXZbr0xhNADej8IQs+YlSdAeM+KJnwp3nQiEPZk/A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Date: Thu, 9 Oct 2014 07:59:35 +0000

> If I use the rtnl_lock(), I get a dead lock when enabling autosuspend.
> 
> Case 1:
>    autosuspend before calling open.
>    rtnl_lock()
>    call open
>    try to autoresume and rtl8152_resume is called.
>    dead lock occurs.
> 
> Case 2:
>    autosuspend occurs.
>    rtnl_lock()
>    call close
>    try to autoresume and rtl8152_resume is called.
>    dead lock occurs.

That's really unfortunate that we can variably get into the resume
handlers from contexts holding the RTNL mutex.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
