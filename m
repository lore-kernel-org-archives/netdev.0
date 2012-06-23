From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Sat, 23 Jun 2012 22:55:13 +0800
Message-ID: <CACVXFVOZUvyNDzEoWT5o7JQRKjuw1pUgkipxV7dxT1w2Dd0H+A@mail.gmail.com>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no>
	<CACVXFVNmquD6nhcJkumZsnXH7T+Ga3YNt9EAQ=-5HUkYwEdp7w@mail.gmail.com>
	<CACVXFVMJSrLjOyKUnZWr3CY2HJT6Wfm6AugZOhSCRUubV0hNMQ@mail.gmail.com>
	<8762aiju27.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	=?ISO-8859-1?Q?Marius_Bj=F8rnstad_Kotsbak?=
	<marius.kotsbak@gmail.com>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:64560 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751186Ab2FWOzO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2012 10:55:14 -0400
In-Reply-To: <8762aiju27.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 23, 2012 at 4:45 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:

> usbnet_disconnect() cannot continue to the point where it frees the
> netdev before wdm_open/wdm_close has completed, because it waits for
> qmi_wwan_unbind which waits for wdm_disconnect. =A0And wdm_disconnect
> takes the both read and write mutexes.

Thanks for your explanation.

I see, and your patch is correct, but it might not be generic enough.

So driver_info->unbind will sync with .open/.close of the subdriver,
just like unregister_netdev will sync with .open/.close of usbnet inter=
face.

IMO, the general solution is to keep intfdata's lifetime after ->unbind=
,
which can guarantee that intfdata can be accessed safely in .open/.clos=
e
of usbnet interface and the other subdrivers' device.

Suppose there will be another usbnet driver which has its own subdriver
too, the same trick of checking need to be added again if not taking th=
e
general way of simply removing 'usb_set_intfdata(intf, NULL);' in
usbnet_disconnect.


Thanks,
--=20
Ming Lei
