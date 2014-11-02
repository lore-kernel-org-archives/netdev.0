From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH net-next v2 2/3] r8152: clear the flagofSCHEDULE_TASKLET in tasklet
Date: Sun, 2 Nov 2014 17:57:16 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2ECD8A7@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-75-Taiwan-albertk@realtek.com>
	<1394712342-15778-79-Taiwan-albertk@realtek.com>
	<1394712342-15778-81-Taiwan-albertk@realtek.com>,<20141031.161520.3547230591227504.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	nic_swsd <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141031.161520.3547230591227504.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Language: zh-TW
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 David Miller [davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org]

> This is racey.

> If another thread of control sets the bit between the test and the
> clear, you will lose an event.

It is fine. The flag is used to schedule a tasklet, so if the tasklet is
starting running, all the other plans for scheduling a tasklet could
be cleared.

Besides, the flag is only set when a transmission occurs and the
device is in autosuspend mode. Then the workqueue could wake
up the device and schedule the tasklet to make sure the tasklet
wouldn't be run when the device is in suspend mode. Therefore,
if the tasklet is running, it means something happens and the
device is waked up. And the queue for scheduling the tasklet is
unnecessary. We don't need the tasklet runs again after current
one except that the relative tx/rx flows schedule it.

> It really never makes sense to work with atomic bitops in a non-atomic
> test-and-whatever manner like this, it's always a red flag and
> indicates you're doing something very wrong.

I use atomic because I don't wish the different threads which
set the different flags would chang the other bits which they
don't interesting in.

Best Regards,
Hayes
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
