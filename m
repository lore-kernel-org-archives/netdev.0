From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH 4/7] usbnet: cdc_mbim: don't recover device if suspend fails in system sleep
Date: Wed, 06 Mar 2013 08:06:10 +0100
Message-ID: <87k3plnh25.fsf@nemi.mork.no>
References: <1362456103-24956-1-git-send-email-ming.lei@canonical.com>
	<1362456103-24956-5-git-send-email-ming.lei@canonical.com>
	<87boayqq5c.fsf@nemi.mork.no>
	<CACVXFVMRpf0REYxfi1wtzUpXn2PTCeS6qNfYQP12tW8ca3Sp=g@mail.gmail.com>
	<87d2veot6t.fsf@nemi.mork.no>
	<CACVXFVOg9cVNYsRuAVkexwy4hvD_iJm_vARRksBAeiWppWnoXA@mail.gmail.com>
	<871ubtq47a.fsf@nemi.mork.no>
	<CACVXFVMDNtJOp+8jMOuhCBjrqq-L=jicEJBr_=ErG19Vr+7OGw@mail.gmail.com>
	<87wqtlommw.fsf@nemi.mork.no>
	<CACVXFVMMtjfea2N7ZMp1j0q_kcg95_RVx6COQ3hGSaxxwftEaw@mail.gmail.com>
	<CACVXFVN=i10cVS3RQ7jGrJAfsC+r2t61z7XOVKWMAMqKKELZCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVN=i10cVS3RQ7jGrJAfsC+r2t61z7XOVKWMAMqKKELZCg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Ming Lei's message of "Wed, 6 Mar 2013 11:03:40 +0800")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:
> On Wed, Mar 6, 2013 at 10:51 AM, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wr=
ote:
>> On Wed, Mar 6, 2013 at 12:08 AM, Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wro=
te:
>>
>>> I guess proper error handling here require the USB core to see the
>>> interface driver as dead if it fails to suspend on system suspend, =
and
>>> do forced rebinding on resume.
>>
>> The idea should be fine, but may cause regression of user space, sup=
pose
>> one device with suspend failure can be across suspend-resume cycle a=
nd
>> work well before, but it is no longer with your forced rebinding.
>
> Give the potential cost(user space regression) of doing rebind, I thi=
nk it
> is better to try to recover the device in resume() first, then
> consider rebinding
> as the last straw.  In fact, I am also wondering if resume() can't re=
cover one
> device but probe() can, maybe we can always let resume() recover the
> device which experienced suspend failure.

Yes, sure. Drivers wanting to do this, anticipating typical errors, can
still return 0 from suspend and do whatever they want in resume.

My proposal is to make the USB core properly deal with drivers returnin=
g
an error from suspend, and also document the fact that a driver should
always return 0 on system suspend unless it really want forced unbindin=
g
on suspend errors.

> I remember that some guys went against rebinding during system sleep =
before
> in the firmware loading discussion.

Yes, that is probably relevant. I'll look it up.  Thanks for the
pointer.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
