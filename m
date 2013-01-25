From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net] net: usbnet: prevent buggy devices from killing us
Date: Fri, 25 Jan 2013 08:13:15 +0100
Message-ID: <87ham5g2gk.fsf@nemi.mork.no>
References: <2556579.vjYlY1iKn5@linux-5eaq.site>
	<1359055016-13603-1-git-send-email-bjorn@mork.no>
	<1794053.fjSaMDVud2@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:50029 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751108Ab3AYHNT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 02:13:19 -0500
In-Reply-To: <1794053.fjSaMDVud2@linux-5eaq.site> (Oliver Neukum's message of
	"Thu, 24 Jan 2013 23:09:26 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oliver@neukum.org> writes:
> On Thursday 24 January 2013 20:16:56 Bj=C3=B8rn Mork wrote:
>> A device sending 0 length frames as fast as it can has been
>> observed killing the host system due to the resulting memory
>> pressure.
>>=20
>> Temporarily disable RX skb allocation and URB submission when
>> the current error ratio is high, preventing us from trying to
>> allocate an infinite number of skbs.  Reenable as soon as we
>> are finished processing the done queue, allowing the device
>> to continue working after short error bursts.
>>=20
>> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
>> ---
>> So is this starting to look OK?
>
> It seems to me that we at least need to try some error recovery.

Won't the disabling code in usbnet_bh do? RX will only stay disabled
until the done queue is handled.

> How about resetting the device when it is no longer used?

Yes, that we should do. I guess usbnet_open is the place to reset the
flag and counters? I'll send another version taking care of this and
Joes comment.


Bj=C3=B8rn
