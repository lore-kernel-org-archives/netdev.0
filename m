From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH net-next v2 2/3] r8152: cleartheflagofSCHEDULE_TASKLETintasklet
Date: Mon, 10 Nov 2014 05:23:14 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2ECE0DF@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-75-Taiwan-albertk@realtek.com>
 <1394712342-15778-79-Taiwan-albertk@realtek.com>
 <1394712342-15778-81-Taiwan-albertk@realtek.com>
 <20141031.161520.3547230591227504.davem@davemloft.net>
 <0835B3720019904CB8F7AA43166CEEB2ECD8A7@RTITMBSV03.realtek.com.tw>
 <20141102225307.GA19900@electric-eye.fr.zoreil.com>
 <0835B3720019904CB8F7AA43166CEEB2ECDFC2@RTITMBSV03.realtek.com.tw>
 <20141108221149.GA26030@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	nic_swsd <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141108221149.GA26030-lmTtMILVy1jWQcoT9B9Ug5SCg42XY1Uw0E9HWUfgJXw@public.gmane.org>
Content-Language: zh-TW
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 Francois Romieu [mailto:romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org] 
> Sent: Sunday, November 09, 2014 6:12 AM
[...]
> The performance explanation leaves me a bit unconvinced. Without any
> figure one could simply go for the always locked clear_bit because of:
> 1. the "I'm racy" message that the open-coded test + set sends
> 2. the extra work needed to avoid 1 (comment, explain, ...).

Thanks. I would modify this patch with clear_bit only.

> The extra time could thus be used to see what happens when napi is
> shoehorned in this tasklet machinery. I'd naively expect it to be
> relevant for efficiency.

I thought about NAPI, but I gave up. The reasons are
1. I don't sure if it would run when autosuspending.
2. There is no hw interrupt for USB device. And I have
   no idea about how to check if the USB transfer is
   completed by polling.
3. I have to control the rx packets numbers in poll().
   However, I couldn't control the packets number for
   each bulk-in transfer. I have to do extra works to
   deal with the rx flow.
4. I don't find much different between tasklet and NAPI.

Best Regards,
Hayes
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
