From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH] USBNET: fix handling padding packet
Date: Thu, 19 Sep 2013 09:18:08 +0200
Message-ID: <87wqmd46vj.fsf@nemi.mork.no>
References: <1379409002-7698-1-git-send-email-ming.lei@canonical.com>
	<878uyu6xjm.fsf@nemi.mork.no>
	<CACVXFVNzTGbCV2wQ4RwxXK1q7+eD2KkOS_G3NvL4uAzdd21SUg@mail.gmail.com>
	<87zjra5dpx.fsf@nemi.mork.no>
	<1379523984.2430.3.camel@linux-fkkt.site>
	<be5ecff3-27e1-4ab7-b3af-9d7c4376140f@email.android.com>
	<1379573843.8608.7.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1379573843.8608.7.camel-B2T3B9s34ElbnMAlSieJcQ@public.gmane.org> (Oliver Neukum's
	message of "Thu, 19 Sep 2013 08:57:23 +0200")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> writes:
> On Wed, 2013-09-18 at 20:56 +0200, Bj=C3=B8rn Mork wrote:
>> Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
>
>> >No, USB 3.0 uses no companion controllers, so you can have devices
>> >of any speed connected to it.
>> >
>>=20
>> Ah, right. I don't own such modern hardware, but I should have known
>> this anyway.
>>=20
>> This still doesn't change the fact that the driver is brand new for
>> brand new devices. I believe we should assume such devices will
>> support ZLPs unless we have documentation stating anything else.
>
> For such devices we might assume it. But how does that matter for
> generic code?

The code isn't generic yet.  Most of it is placed inside the
ax88179_178a minidriver.

But I do agree that adding this padding support can be seen as one step
towards making the code generic.  So if you really anticipate this bein=
g
enabled for e.g. the ECM class driver, then yes, padding must be
supported.

I would have had less trouble understanding the value if this patch was
part of a generalisation series, though...

> As any kind of device may be connected to XHCI, the sg
> code is relevant for every driver. And I certainly don't want trouble
> for older devices' drivers converted to sg.

I wonder what the gain of that really is?  Yes, I can see the advantage
of making the class drivers more effective.  But padding is only
relevant for the ECM class, isn't it? And are there any ECM class
devices where SG support matters?


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
