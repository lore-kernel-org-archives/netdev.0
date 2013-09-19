From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH] USBNET: fix handling padding packet
Date: Thu, 19 Sep 2013 21:08:08 +0800
Message-ID: <CACVXFVPOyr3eDrJxGhmoxDdZS2FL17qm6jv0ezDECUAk267jFg@mail.gmail.com>
References: <1379409002-7698-1-git-send-email-ming.lei@canonical.com>
	<878uyu6xjm.fsf@nemi.mork.no>
	<CACVXFVNzTGbCV2wQ4RwxXK1q7+eD2KkOS_G3NvL4uAzdd21SUg@mail.gmail.com>
	<87zjra5dpx.fsf@nemi.mork.no>
	<1379523984.2430.3.camel@linux-fkkt.site>
	<be5ecff3-27e1-4ab7-b3af-9d7c4376140f@email.android.com>
	<1379573843.8608.7.camel@linux-fkkt.site>
	<87wqmd46vj.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87wqmd46vj.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 19, 2013 at 3:18 PM, Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote:
> Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> writes:
>> On Wed, 2013-09-18 at 20:56 +0200, Bj=F8rn Mork wrote:
>>> Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
>>
>>> >No, USB 3.0 uses no companion controllers, so you can have devices
>>> >of any speed connected to it.
>>> >
>>>
>>> Ah, right. I don't own such modern hardware, but I should have know=
n
>>> this anyway.
>>>
>>> This still doesn't change the fact that the driver is brand new for
>>> brand new devices. I believe we should assume such devices will
>>> support ZLPs unless we have documentation stating anything else.
>>
>> For such devices we might assume it. But how does that matter for
>> generic code?
>
> The code isn't generic yet.  Most of it is placed inside the
> ax88179_178a minidriver.

No, the patch doesn't touch code of ax99179_178a.

And it is really generic to fix the padding in case of dma sg.

>
> But I do agree that adding this padding support can be seen as one st=
ep
> towards making the code generic.  So if you really anticipate this be=
ing
> enabled for e.g. the ECM class driver, then yes, padding must be
> supported.

1byte padding frame is already supported by usbnet before, isn't it?

>
> I would have had less trouble understanding the value if this patch w=
as
> part of a generalisation series, though...

As my below test on ax99179_178a, I believe the patch should fix paddin=
g
for dma sg, but need a little update, and I will send out v1 later:

           $ping -s 974 another_machine  #from host with ax99179_178a a=
ttached

If FLAG_SEND_ZLP is set for ax99179_178a, the above ping won't work any
more either on USB3.0 or USB 2.0 host controller.

So don't assume that these brand new devices can support ZLP well.

>
>> As any kind of device may be connected to XHCI, the sg
>> code is relevant for every driver. And I certainly don't want troubl=
e
>> for older devices' drivers converted to sg.
>
> I wonder what the gain of that really is?  Yes, I can see the advanta=
ge
> of making the class drivers more effective.  But padding is only
> relevant for the ECM class, isn't it? And are there any ECM class
> devices where SG support matters?

Why is padding only relevant for the ECM? Of course, other devices
need it too, such as asix devices.

Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
