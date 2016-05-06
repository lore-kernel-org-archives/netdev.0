From: John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [REGRESSION] asix: Lots of asix_rx_fixup() errors and slow transmissions
Date: Fri, 6 May 2016 11:38:30 -0700
Message-ID: <CALAqxLXXs77yxahw_H+u02uSdN8WOxdjdXVxhxB4YJGssumY4Q@mail.gmail.com>
References: <CALAqxLUj+-yUGTNviHu4+KE9=JTxjZyHBv4pdUob=xndAr8ZmA@mail.gmail.com>
	<87ed4c76328ed9dc5591359ea0e98ab9@i4031.net>
	<57291539.6080405@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David B. Robins" <linux-AegXhGwVzVhoAEGGzP886w@public.gmane.org>,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Mark Craske <Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	YongQin Liu <yongqin.liu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Guodong Xu <guodong.xu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ivan Vecera <ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Dean Jenkins <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <57291539.6080405-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 3, 2016 at 2:16 PM, Dean Jenkins <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org> wrote:
> A good test would be to run "ping -c 1 -s $packet_length $ip_address" inside
> a script which has a loop with an increasing payload length $packet_length
> with a small delay between ping calls. This will show whether particular
> packet sizes trigger the failures.
>
> Then try with "ping -f -c 200 -s $packet_length $ip_address" to load up the
> USB link.

I've tried both of these on my x86_64 system.  I can send single pings
up to 65507 without triggering the issue (after which I get errors
sending on the host side as I think I cross a 64k boundary with
headers, not the asix errors).

Then when I try ping -f -c 200 -s 65507 $ip_address, I don't see any
failures. I did it for a count of 2000 as well without any issues.

I'll be adding more debug prints in soon.

thanks
-john
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
