From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: Potential problem in drivers/net/wireless/rtlwifi/usb.c:_rtl_rx_pre_process()
Date: Sun, 27 Jan 2013 16:11:51 -0600
Message-ID: <5105A627.5000208@lwfinger.net>
References: <20130127211811.GA6680@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130127211811.GA6680-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/27/2013 03:18 PM, Guenter Roeck wrote:
> Hi all,
>
> while browsing through 'warning: variable =E2=80=98...=E2=80=99 set b=
ut not used' warnings, I
> found the following code in drivers/net/wireless/rtlwifi/usb.c:_rtl_r=
x_pre_process().
>
> 	while (!skb_queue_empty(&rx_queue)) {
>          	_skb =3D skb_dequeue(&rx_queue);
> 		_rtl_usb_rx_process_agg(hw, skb);
> 		ieee80211_rx_irqsafe(hw, skb);
> 	}
>
> Question: Should the parameter to _rtl_usb_rx_process_agg() and
> ieee80211_rx_irqsafe() be '_skb' instead of 'skb' ?

I think you are right and I will submit a patch to fix this.

What compiler version reported this? I use "gcc (SUSE Linux) 4.7.2 2013=
0108=20
[gcc-4_7-branch revision 195012]" and I do not see this warning.

Thanks,

Larry


--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
