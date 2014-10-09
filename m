From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH net-next] r8152: use mutex for hw settings
Date: Thu, 9 Oct 2014 07:59:35 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2EC397B@RTITMBSTEMP01.realtek.com.tw>
References: <1394712342-15778-58-Taiwan-albertk@realtek.com>
 <20141008.154513.1944594723904521723.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	nic_swsd <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141008.154513.1944594723904521723.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Language: zh-TW
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 David Miller [mailto:davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org] 
> Sent: Thursday, October 09, 2014 3:45 AM
[..]
> I think a much simpler fix is to take rtnl_lock() in the workqueue
> function and suspend/resume ops.
> 
> Every other place you are adding the mutex already holds the RTNL
> mutex.

If I use the rtnl_lock(), I get a dead lock when enabling autosuspend.

Case 1:
   autosuspend before calling open.
   rtnl_lock()
   call open
   try to autoresume and rtl8152_resume is called.
   dead lock occurs.

Case 2:
   autosuspend occurs.
   rtnl_lock()
   call close
   try to autoresume and rtl8152_resume is called.
   dead lock occurs.
 
Best Regards,
Hayes
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
