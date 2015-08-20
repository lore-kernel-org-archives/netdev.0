From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: Re^2:: [PATCH] usbnet: dereference after null check in usbnet_start_xmit() and __usbnet_read_cmd()
Date: Thu, 20 Aug 2015 09:16:31 +0200
Message-ID: <87zj1mctv4.fsf@nemi.mork.no>
References: <140453008.311141440043155179.JavaMail.weblogic@ep2mlwas02d>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Nitin Jhanwar <nitin.j@samsung.com>,
	HEMANSHU SRIVASTAVA <hemanshu.s@samsung.com>
To: Vivek Kumar Bhagat <vivek.bhagat@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:57907 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751670AbbHTHQp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 03:16:45 -0400
In-Reply-To: <140453008.311141440043155179.JavaMail.weblogic@ep2mlwas02d>
	(Vivek Kumar Bhagat's message of "Thu, 20 Aug 2015 03:59:15 +0000
	(GMT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vivek Kumar Bhagat <vivek.bhagat@samsung.com> writes:

> Dear Bjorn,
>
>>> This is wrong.  There are usbnet minidrivers depending on info->tx_=
fixup
>>> being called with a NULL skb.
> I am using ax88179_178a driver and not familiar with usbnet minidrive=
rs.
> When ax88179_tx_fixup() is called with NULL skb from
> usbnet_start_xmit(), I get a kernel crash.
>     Backtrace:
>     09:14:569>[0-553.5598] [<befaa194>] (ax88179_tx_fixup+0x0/0x16c [=
ax88179_178a]) from [<befef7a8>] (usbnet_start_xmit+0xa
>     09:14:569>0/0x420 [usbnet])
>     09:14:570>[0-553.5711]  r6:cb5ec280 r5:00000000 r4:cb5ebd40
>     09:14:572>[0-553.5755] [<befef708>] (usbnet_start_xmit+0x0/0x420 =
[usbnet]) from [<c0400040>] (dev_hard_start_xmit+0x2ec/
>     09:14:572>0x558)
>     09:14:572>[0-553.5858] [<c03ffd54>] (dev_hard_start_xmit+0x0/0x55=
8)
> In case skb NULL check can not be added in usbnet_start_xmit()
> then NULL check is required in ax88179_tx_fixup() or asix_tx_fixup().

Yes.

Or you could add the check to usbnet_start_xmit() if you remove the ugl=
y
hack in the minidrivers calling usbnet_start_xmit with skb =3D=3D NULL =
first.
This is cdc_ncm and those depending on cdc_ncm.

But it would also be interesting to know why ax88179_tx_fixup() is
called with a NULL skb. I believe this should not happen.  Do you have
any idea?

cdc_ncm, which is the driver depending on the NULL skb input, will
explicitly call
  usbnet_start_xmit(NULL, dev->net);

I don't know any other way this could happen.



Bj=C3=B8rn
