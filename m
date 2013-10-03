From: "Dr. H. Nikolaus Schaller" <hns-xXXSsgcRVICgSpxsJD1C4w@public.gmane.org>
Subject: Re: [PATCH 1/1] hso: fix problem with wrong status code sent by OPTION GTM601 during RING indication
Date: Thu, 3 Oct 2013 21:40:34 +0200
Message-ID: <C7520082-95CC-4D4F-BCE4-96A7D6346DB3@goldelico.com>
References: <B1808224-5850-41E3-9A8F-0F350F84FF89@goldelico.com> <20131003.152907.2144013596237714581.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	Belisko Marek <marek.belisko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20131003.152907.2144013596237714581.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Am 03.10.2013 um 21:29 schrieb David Miller:

> From: "Dr. H. Nikolaus Schaller" <hns-xXXSsgcRVICgSpxsJD1C4w@public.gmane.org>
> Date: Wed, 2 Oct 2013 09:00:18 +0200
> 
>> From f5c7e15b61f2ce4fe3105ff914f6bfaf5d74af0d Mon Sep 17 00:00:00 2001
>> From: "H. Nikolaus Schaller" <hns-xXXSsgcRVICgSpxsJD1C4w@public.gmane.org>
>> Date: Thu, 15 Nov 2012 14:40:57 +0100
>> Subject: [PATCH 1/1] hso: fix problem with wrong status code sent by OPTION
>> GTM601 during RING indication
>> 
>> It has been observed that the GTM601 with 1.7 firmware sometimes sends a value
>> wIndex that has bit 0x04 set instead of being reset as the code expects. So we
>> mask it for the error check.
>> 
>> See http://lists.goldelico.com/pipermail/gta04-owner/2012-February/001643.html
>> 
>> Signed-off-by: NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>
>> Signed-off-by: H. Nikolaus Schaller <hns-xXXSsgcRVIAdwXzzRB9H2Q@public.gmane.org>
> 
> I think we should look more deeply into what this bit might mean
> and why the firmware might be setting it before we even consider
> applying a patch like this one.

Yes, that would be the right way.

The problem is that the firmware is a black box and the packet format has no
(public) documentation (unless someone inside OPTION has access to it).

I have made the bug observation from debug log that this bit is set in a response
each time the modem has a RING message. It might be specific to this modem
and firmware version, i.e. a firmware bug. But we have no means to verify or even
change it in the firmware.

I.e. the driver must handle it in a better way.

Because the notification is rejected by the driver, the driver will hang up and the
whole modem connection breaks down.

With this patch, the problem was never observed again in ~2 years.

I'd hope the maintainer of this driver can shed some light on it.

BR,
Nikolaus Schaller

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
