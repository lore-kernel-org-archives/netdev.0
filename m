From: Wei Shuai <cpuwolf@gmail.com>
Subject: Re: [PATCH] CDC_NCM adding support IFF_NOARP for infineon modem platform
Date: Tue, 15 Jan 2013 21:11:34 +0800
Message-ID: <CACa7zymy1kg7N9WZjf=u=VGw=GeOJrzvRzRj11LZdKWnuAvgcA@mail.gmail.com>
References: <1357990479-5836-1-git-send-email-cpuwolf@gmail.com>
	<20130112.153533.1713284383322153346.davem@davemloft.net>
	<1358183953.1713.28.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Alexey Orishko <alexey.orishko@stericsson.com>,
	=?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:57178 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755379Ab3AONLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 08:11:35 -0500
In-Reply-To: <1358183953.1713.28.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

yes. usbnet has FLAG_POINTTOPOINT, but that's nothing to do with
IFF_POINTTOPOINT. At least we should do something to handle
relationship of these flags rather than only have different names.
or new flag FLAG_NOARP could be introduced to corresponding to IFF_NOARP.

2013/1/15 Dan Williams <dcbw@redhat.com>:
> On Sat, 2013-01-12 at 15:35 -0800, David Miller wrote:
>> From: Wei Shuai <cpuwolf@gmail.com>
>> Date: Sat, 12 Jan 2013 19:34:39 +0800
>>
>> > Infineon(now Intel) HSPA Modem platform NCM cannot support ARP. so I
>> > introduce a flag CDC_NCM_DRIVER_DATA_NOARP which is defined in
>> > driver_info:data. so later on, if more such buggy devices are found,
>> > they could use same flag to handle.
>>
>> Is it no able to do ARP or, the more likely case, does broadcast
>> not work at all?
>>
>> If it's the latter, IFF_NOARP is just making over the real problem.
>>
>> I'm not applying this, no hardware device should set IFF_NOARP.
>> You probably really want IFF_POINTOPOINT or similar.
>
> IFF_NOARP is already done for other WWAN devices (sierra_net, hso,
> cdc-ether, cdc-phonet, lg-vl600, etc) so there is some precedent.  Some
> drivers (phonet, hso) set *both* POINTTOPOINT and NOARP.  Is that
> redundant, and should all WWAN drivers be moved to only POINTTOPOINT?
>
> (aside: usbnet has FLAG_POINTTOPOINT, but that's nothing to do with
> IFF_POINTTOPOINT, it only controls whether the interface is named usbX
> or ethX.  Confusing.)
>
> Dan
>
