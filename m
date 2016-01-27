From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RESEND net] nfc: use GFP_USER for user-controlled kmalloc
Date: Wed, 27 Jan 2016 13:05:52 -0800
Message-ID: <1453928752.20722.27.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1453830820-27104-1-git-send-email-xiyou.wangcong@gmail.com>
	 <CAGRGNgV7MUXdk+e8Arx05yiWX6owei5dmnFQ-TBfs55jfy+qBw@mail.gmail.com>
	 <CAM_iQpWawou1Z_NnAzM5TxH7TUQUCAhf+k96PErNV8q_SOCShw@mail.gmail.com>
	 <1453861388.11327.51.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAM_iQpXOEQhwPp6HD3L16DV1tygEyKNoHH+zHkukux7zYzaJeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAM_iQpXOEQhwPp6HD3L16DV1tygEyKNoHH+zHkukux7zYzaJeA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-01-27 at 11:50 -0800, Cong Wang wrote:

> Hmm? I think nfc_llcp_send_ui_frame() needs to do some fragmention
> with this temporary memory, or you are saying msg_iter has some
> API available to seek the pointer? Even if so, it doesn't look like
> suitable for -stable.
> 

memcpy_from_msg(msg_data, msg, len) will overwrite the msg_data with len
bytes, or return an error.

So prior msg_data content does not matter.

kzalloc() before a memset() or memcpy() sounds defensive programming,
kmalloc() is a bit faster.



--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
