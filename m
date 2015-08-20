From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] usbnet: dereference after null check in usbnet_start_xmit() and __usbnet_read_cmd()
Date: Thu, 20 Aug 2015 09:29:05 +0200
Message-ID: <87vbcacta6.fsf@nemi.mork.no>
References: <317402377.314001440045815822.JavaMail.weblogic@ep2mlwas02d>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Nitin Jhanwar <nitin.j@samsung.com>,
	HEMANSHU SRIVASTAVA <hemanshu.s@samsung.com>
To: Vivek Kumar Bhagat <vivek.bhagat@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:35388 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752317AbbHTH3U convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 03:29:20 -0400
In-Reply-To: <317402377.314001440045815822.JavaMail.weblogic@ep2mlwas02d>
	(Vivek Kumar Bhagat's message of "Thu, 20 Aug 2015 04:43:35 +0000
	(GMT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vivek Kumar Bhagat <vivek.bhagat@samsung.com> writes:

> Dear Bjorn,
>
>>>This is wrong.  There are usbnet minidrivers depending on info->tx_f=
ixup
>>> being called with a NULL skb.
> Also, if dev_hard_start_xmit() ensures that skb can not be NULL in us=
bnet_start_xmit()
> then we should remove below check.
>     if (skb)      <--- This check is confusing which says skb can be =
NULL.
>                 skb_tx_timestamp(skb);=20


No, that test is there because of the ugly hack in cdc_ncm.  It doesn't
go through dev_hard_start_xmit(), but calls usbnet_start_xmit() directl=
y
with a NULL skb as a signal to itself.  Yes, I told you it was ugly ;)

I do agree that it would be nice to make this go away.  But until that
happens usbnet_start_xmit() has to deal with NULL skbs, forwarding them
to the tx_fixup hook.


Bj=C3=B8rn
