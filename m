From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next 02/14] net: cdc_ncm: use device rx_max value if update failed
Date: Fri, 19 Oct 2012 00:09:08 +0200
Message-ID: <87ehkvv3ej.fsf@nemi.mork.no>
References: <1350592867-25651-1-git-send-email-bjorn@mork.no>
	<1350592867-25651-3-git-send-email-bjorn@mork.no>
	<3426241.1WN6uXHlgW@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Greg Suarez <gpsuarez2512@gmail.com>,
	"Fangxiaozhi \(Franko\)" <fangxiaozhi@huawei.com>,
	Dan Williams <dcbw@redhat.com>,
	Aleksander Morgado <aleksander@lanedo.com>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:34002 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751758Ab2JRWJl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 18:09:41 -0400
In-Reply-To: <3426241.1WN6uXHlgW@linux-lqwf.site> (Oliver Neukum's message of
	"Thu, 18 Oct 2012 23:45:50 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oliver@neukum.org> writes:
> On Thursday 18 October 2012 22:40:55 Bj=C3=B8rn Mork wrote:
>> If the device refuses our updated value, then we must be prepared
>> to receive URBs as big as the device wants to send.  Set rx_max
>> to the device provided value on error.
>
> Problematic in principle. How do you allocate a buffer of arbitrary s=
ize?

You cannot of course.  You can only try and give up if it doesn't work.
rx_submit would end up returning -ENOMEM, but we are not always checkin=
g
that so it will most likely fail silently.

But I don't think we can just continue with the smaller buffer size
without having the device agree to that either.  That is also likely to
fail silently.  Note that this patch was added exactly because one of
the MBIM test devices did refuse the lower rx_max we tried to enforce.
The device insists on using 128kB buffers.

Maybe we should cap it at some arbitrary reasonable value, and just bai=
l
out from bind if the device insists on a larger buffer?  Would that be
OK?  How big buffers are (semi-)reasonable?


Bj=C3=B8rn
