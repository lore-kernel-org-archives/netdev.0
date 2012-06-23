From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Sat, 23 Jun 2012 17:32:09 +0200
Message-ID: <87hau2hwna.fsf@nemi.mork.no>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no>
	<CACVXFVNmquD6nhcJkumZsnXH7T+Ga3YNt9EAQ=-5HUkYwEdp7w@mail.gmail.com>
	<CACVXFVMJSrLjOyKUnZWr3CY2HJT6Wfm6AugZOhSCRUubV0hNMQ@mail.gmail.com>
	<8762aiju27.fsf@nemi.mork.no>
	<CACVXFVOZUvyNDzEoWT5o7JQRKjuw1pUgkipxV7dxT1w2Dd0H+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Marius =?utf-8?Q?Bj=C3=B8rnstad?= Kotsbak
	<marius.kotsbak@gmail.com>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:42323 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755824Ab2FWTvZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2012 15:51:25 -0400
In-Reply-To: <CACVXFVOZUvyNDzEoWT5o7JQRKjuw1pUgkipxV7dxT1w2Dd0H+A@mail.gmail.com>
	(Ming Lei's message of "Sat, 23 Jun 2012 22:55:13 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ming Lei <tom.leiming@gmail.com> writes:
> On Sat, Jun 23, 2012 at 4:45 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrot=
e:
>
>> usbnet_disconnect() cannot continue to the point where it frees the
>> netdev before wdm_open/wdm_close has completed, because it waits for
>> qmi_wwan_unbind which waits for wdm_disconnect. =C2=A0And wdm_discon=
nect
>> takes the both read and write mutexes.
>
> Thanks for your explanation.
>
> I see, and your patch is correct, but it might not be generic enough.
>
> So driver_info->unbind will sync with .open/.close of the subdriver,
> just like unregister_netdev will sync with .open/.close of usbnet int=
erface.
>
> IMO, the general solution is to keep intfdata's lifetime after ->unbi=
nd,
> which can guarantee that intfdata can be accessed safely in .open/.cl=
ose
> of usbnet interface and the other subdrivers' device.
>
> Suppose there will be another usbnet driver which has its own subdriv=
er
> too, the same trick of checking need to be added again if not taking =
the
> general way of simply removing 'usb_set_intfdata(intf, NULL);' in
> usbnet_disconnect.

Yes, I guess so.

I am just worrying (maybe too much) about the unknown consequences of
removing that code in usbnet, not fully understanding why it was there
in the first place.  And I do not want to take the blame and cleanup
work if anything goes wrong :-) Fixing it in qmi_wwan feels much safer.

But if you want to remove the 'usb_set_intfdata(intf, NULL)', and the
other USB gurus agree, then I'm of course not going to object to that
alternative solution to this bug.

I still think it's unlikely this will ever hit another driver though.=20


Bj=C3=B8rn
