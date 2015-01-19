From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 1/7] r8152: adjust rx_bottom
Date: Mon, 19 Jan 2015 16:13:33 -0500 (EST)
Message-ID: <20150119.161333.1471925264489559119.davem@davemloft.net>
References: <1394712342-15778-118-Taiwan-albertk@realtek.com>
	<1394712342-15778-119-Taiwan-albertk@realtek.com>
	<CAE4R7bAv26f-+DW-TmjspJxAb-3Add5sf563mnMUTGCyiqG3rQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: sfeldma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAE4R7bAv26f-+DW-TmjspJxAb-3Add5sf563mnMUTGCyiqG3rQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Scott Feldman <sfeldma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 19 Jan 2015 00:03:42 -0800

> On Sun, Jan 18, 2015 at 11:13 PM, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org> wrote:
>> @@ -1746,7 +1746,18 @@ find_next_rx:
>>                 }
>>
>>  submit:
>> -               r8152_submit_rx(tp, agg, GFP_ATOMIC);
>> +               if (!ret) {
>> +                       ret = r8152_submit_rx(tp, agg, GFP_ATOMIC);
>> +               } else {
>> +                       urb->actual_length = 0;
>> +                       list_add_tail(&agg->list, next);
> 
> Do you need a spin_lock_irqsave(&tp->rx_lock, flags) around this?

Indeed, and rtl_start_rx() seems to also access agg->list without
proper locking.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
