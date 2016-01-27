From: Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RESEND net] nfc: use GFP_USER for user-controlled kmalloc
Date: Wed, 27 Jan 2016 11:50:10 -0800
Message-ID: <CAM_iQpXOEQhwPp6HD3L16DV1tygEyKNoHH+zHkukux7zYzaJeA@mail.gmail.com>
References: <1453830820-27104-1-git-send-email-xiyou.wangcong@gmail.com>
	<CAGRGNgV7MUXdk+e8Arx05yiWX6owei5dmnFQ-TBfs55jfy+qBw@mail.gmail.com>
	<CAM_iQpWawou1Z_NnAzM5TxH7TUQUCAhf+k96PErNV8q_SOCShw@mail.gmail.com>
	<1453861388.11327.51.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1453861388.11327.51.camel-XN9IlZ5yJG9HTL0Zs8A6p/gx64E7kk8eUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 26, 2016 at 6:23 PM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Tue, 2016-01-26 at 15:12 -0800, Cong Wang wrote:
>> On Tue, Jan 26, 2016 at 2:55 PM, Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> > Hi Cong,
>> >
>> > On Wed, Jan 27, 2016 at 4:53 AM, Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> >
>> > A commit message would be nice. A brief rundown of how this is called
>> > from userspace would be nice (I'm talking a single sentence here, e.g.
>> > "this is allocated when submitting a nfc packet") and what issue
>> > __GFP_NOWARN is fixing. (I'm guessing log spam due to allocation
>> > failures.)
>> >
>>
>> I thought it is obvious. ;) Keep in mind that $subject is one part of commit
>> message too, so there is a commit message although very short.
>>
>> I will add it.
>
>
> BTW, kzalloc() is useless here, since it is followed by
>
> if (memcpy_from_msg(msg_data, msg, len)) {

Hmm? I think nfc_llcp_send_ui_frame() needs to do some fragmention
with this temporary memory, or you are saying msg_iter has some
API available to seek the pointer? Even if so, it doesn't look like
suitable for -stable.

>
> Also, this file seems to have two spots with the same problem,
> in nfc_llcp_send_ui_frame() & nfc_llcp_send_i_frame()
>

Ah, yes, I missed nfc_llcp_send_i_frame().
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
