From: Alexey Orishko <alexey.orishko@gmail.com>
Subject: Re: [PATCH net-next 02/14] net: cdc_ncm: use device rx_max value if
 update failed
Date: Fri, 19 Oct 2012 01:30:01 +0200
Message-ID: <CAL_Kpj0j9umyQBFFDVqWqEjH1057EjR0cZRcScdZG30E54=M0w@mail.gmail.com>
References: <1350592867-25651-1-git-send-email-bjorn@mork.no>
	<1350592867-25651-3-git-send-email-bjorn@mork.no>
	<3426241.1WN6uXHlgW@linux-lqwf.site>
	<87ehkvv3ej.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Greg Suarez <gpsuarez2512@gmail.com>,
	"Fangxiaozhi (Franko)" <fangxiaozhi@huawei.com>,
	Dan Williams <dcbw@redhat.com>,
	Aleksander Morgado <aleksander@lanedo.com>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:54636 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754037Ab2JRXaC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 19:30:02 -0400
In-Reply-To: <87ehkvv3ej.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 19, 2012 at 12:09 AM, Bj=F8rn Mork <bjorn@mork.no> wrote:
> Oliver Neukum <oliver@neukum.org> writes:
>> On Thursday 18 October 2012 22:40:55 Bj=F8rn Mork wrote:
>>> If the device refuses our updated value, then we must be prepared
>>> to receive URBs as big as the device wants to send.  Set rx_max
>>> to the device provided value on error.
>>
>> Problematic in principle. How do you allocate a buffer of arbitrary =
size?
>
> You cannot of course.  You can only try and give up if it doesn't wor=
k.
> rx_submit would end up returning -ENOMEM, but we are not always check=
ing
> that so it will most likely fail silently.
>
> But I don't think we can just continue with the smaller buffer size
> without having the device agree to that either.  That is also likely =
to
> fail silently.  Note that this patch was added exactly because one of
> the MBIM test devices did refuse the lower rx_max we tried to enforce=
=2E
> The device insists on using 128kB buffers.
>
> Maybe we should cap it at some arbitrary reasonable value, and just b=
ail
> out from bind if the device insists on a larger buffer?  Would that b=
e
> OK?  How big buffers are (semi-)reasonable?
>

I recommend to drop this.Vendor has to fix firmware.
Current version of the driver supports 16-bit NTB, which means you can =
address
(64K only - NTB header). So, how do you plan to use 64K-128K buffer spa=
ce,
if it can't be addressed by 16 bit offset?
Another angle to big buffers, even while using 64K buffers your TCP con=
nection
will suffer, so what's the point making huge buffers?

/alexey
