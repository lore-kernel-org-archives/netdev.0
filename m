From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] net:usb:cdc_ncm: fix that tag Huawei devices as wwan
Date: Mon, 15 Jun 2015 13:25:35 +0200
Message-ID: <EA652056-E807-4977-AF2A-8BF7E3E41DFD@holtmann.org>
References: <SNT147-W99A0E937260823EBAA1FFB3B90@phx.gbl> <CA+55aFz3S3nR_aDMMS1vcayyEqJCBL5tgoYAfDE2WGyM3Vcrww@mail.gmail.com> <87ioapl55s.fsf@nemi.mork.no> <30508675-5839-4E65-975A-4CFC5B1C5E24@holtmann.org> <87a8w1kz3a.fsf@nemi.mork.no>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Ben Hutchings <ben.hutchings-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	xiaomao <xiaomao0213-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
To: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87a8w1kz3a.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Bjorn,

>> we introduced DEVTYPE in uevent a long time ago. That is what
>> userspace should be using and not second guessing on interface names.
> 
> Yes, sorry for confusing this by mentioning the device name.  This is
> really about DEVTYPE.
> 
> usbnet minidrivers use FLAG_WWAN to set both the 'wwanX' device name and
> DEVTYPE=wwan. The question here is whether or not to set that flag for
> Huawei NCM devices.  We can discuss that in the DEVTYPE context if you
> prefer.
> 
>> Why is userspace trying to hack around the kernel anyway.
> 
> Because you can never expect DEVTYPE to be 100% correct. There isn't a
> one-to-one relationship between USB classes and DEVTYPE. So we use a
> default DEVTYPE and exception lists in class drivers like cdc_ether and
> cdc_ncm.  These exception lists will always be incomplete, like any such
> whitelist/blacklist.
> 
> I believe we have discussed this before, and my opinion on DEVTYPE is
> still that it is a best effort thing which we would have been better off
> without.  But it's too late to do anything about that.  Userspace has to
> deal with it.  The kernel provides a hint.  The hint cannot be trusted.

if this is a 2G/3G/LTE or whatever card providing broadband networking then this is DEVTYPE=wwan. It makes no difference if this is NCM or not. It is important to know what this network interface connects to.

>> This never
>> really goes well unless the kernel exposes clear information to
>> identify devices. If there are some weird devices, then work this out
>> in the kernel and have DEVTYPE identity them correctly.
> 
> How?  These devices share device IDs. We do not touch their management
> interfaces from the kernel.  We depend on being able to classify device
> types based on USB descriptors. How can we identify which device is wwan
> and which is not if the descriptors are identical down to the device ID?

What is Huawei building besides broadband cards? Are they in the business of WiFi or Ethernet now?

> It is tempting to say that Huawei knows best for their own devices, if
> you all find the change acceptable.  I most certainly don't know better
> than they do. I would have loved to travel back in time and never submit
> that patch...

I mean if this is about distinguishing their phones from their data cards, then surely the other USB descriptors are different so that the driver can quirk this correctly.

Regards

Marcel

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
