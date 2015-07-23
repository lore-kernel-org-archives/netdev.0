From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Subject: Re: Several races in "usbnet" module (kernel 4.1.x)
Date: Thu, 23 Jul 2015 14:39:42 +0300
Message-ID: <55B0D27E.8090701@rosalab.ru>
References: <55AD3A41.2040100@rosalab.ru> <1437644594.4377.12.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from collab.rosalab.ru ([195.19.76.181]:48679 "EHLO
	collab.rosalab.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025AbbGWLjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 07:39:46 -0400
In-Reply-To: <1437644594.4377.12.camel@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

23.07.2015 12:43, Oliver Neukum =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Mon, 2015-07-20 at 21:13 +0300, Eugene Shatokhin wrote:
>> [Race #5]
>>
>> Race on dev->rx_urb_size. I reproduced it a similar way as the races
>> #2
>> and #3 (changing MTU while downloading files).
>>
>> dev->rx_urb_size is written to here:
>> #0  usbnet_change_mtu (usbnet.c:392)
>>          dev->rx_urb_size =3D dev->hard_mtu;
>>
>> Here is the conflicting read from dev->rx_urb_size:
>> * rx_submit (usbnet.c:467)
>>          size_t                  size =3D dev->rx_urb_size;
>
> Yes, but what is the actual bad race? I mean, if you change
> the MTU in operation, there will be a race. That is just
> unavoidable.
> Do we generate errors?

No, I have observed no problems due to this race so far.

Regards,
Eugene
