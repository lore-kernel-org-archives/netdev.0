From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH] rndis_host: support Novatel Verizon USB730L
Date: Tue, 03 Oct 2017 16:01:15 +0200
Message-ID: <87k20cmitw.fsf@miraculix.mork.no>
References: <20170927213103.11987-1-aleksander@aleksander.es>
        <20171002.161750.1123671129875495210.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171002.161750.1123671129875495210.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (David
        Miller's message of "Mon, 02 Oct 2017 16:17:50 -0700 (PDT)")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:

> From: Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
> Date: Wed, 27 Sep 2017 23:31:03 +0200
>
>> I'm not sure if binding this logic to a specific vid:pid (1410:9030)
>> would be more appropriate here, or if it's ok to just bind
>> class/subclass/protocol (as in the activesync case).  Let me know
>> what you think.
>
> I don't have enough USB Networking knowledge to make a decision here.
>
> Some things seem confusing.  For example, if we should be matching
> USB_CLASS_MISC, subclass=3D4, protocol=3D1 for RNDIS over Ethernet, then
> we why aren't we also matching USB_CLASS_MISC, subclass=3D4, protocol=3D2
> for RNDIS over wireless and instead are matching "Remote RNDIS" in
> the form of USB_CLASS_WIRELSS, subclass=3D1, protocol=3D3?
>
> I really don't understand any of this magic :-)
>
> So someone more knowledgable needs to review this.

Let me just say that I am not qualified.  But since this needs a review,
I am going to offer my view anyway.  FWIW, I don't think *anyone*
understand this magic...  I certainly don't.

We can pretty much ignore the USB-IF and any specs, since that is what
the vendors appear to do.  They provide device specific drivers for
Windows, so all they care about is that their device "works" with their
driver.

But in Linux we prefer to create drivers for device classes whenever we
can, to avoid having to add every single device by ID.  So we try to
guess future patterns based on the devices we have observed, even when
there is no clear spec.  This is what Aleksander does here. He has a
device with a 'Cls=3Def(misc ) Sub=3D04 Prot=3D01' function.  This device
works with the rndis_host driver. That is all we know.

We cannot prove that a class match is correct. But it does make sense to
try it.  At least we know that this works for one device.

Adding anything else, e.g. based on the table at
http://www.usb.org/developers/defined_class/#BaseClassEFh , is a bit
more risky.  We don't know if a driver will work with *any* such device
until we've actually seen one.

This is just my opinion, and probably full of bogus assumptions as
usual.  I was sort of hoping that some expert would speak up so I didn't
have to :-)

But FWIW:

Reviewed-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>



Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
