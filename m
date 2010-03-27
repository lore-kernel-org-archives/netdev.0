From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: r8169 mac reading/writing broken
Date: Sat, 27 Mar 2010 22:37:38 +0200
Message-ID: <4BAE6C92.2060801@iki.fi>
References: <4BADDDB7.4010005@iki.fi> <20100327114059.GA3432@electric-eye.fr.zoreil.com> <4BADF01E.9090906@iki.fi> <20100327120358.GA5114@electric-eye.fr.zoreil.com> <4BADF738.2060600@iki.fi> <20100327122642.GA5165@electric-eye.fr.zoreil.com> <4BADFAE4.5040906@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ivan Vecera <ivecera@redhat.com>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Fran=E7ois_Romieu?= <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:40730 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753939Ab0C0Uhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 16:37:43 -0400
Received: by ey-out-2122.google.com with SMTP id d26so1041083eyd.19
        for <netdev@vger.kernel.org>; Sat, 27 Mar 2010 13:37:41 -0700 (PDT)
In-Reply-To: <4BADFAE4.5040906@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s wrote:
> Fran=E7ois Romieu wrote:
>> Timo Ter=E4s <timo.teras@iki.fi> :
>> [...]
>>> It seems that adding single printk between writing MAC0 and MAC4=20
>>> fixes it.
>>> I guess it needs a bit of delay between the writes or something.
>>
>> Can you test with a single RTL_R32 after each MACx write ?
>=20
> Adding reading back of the written value fixes it too. Though,
> disassembly says that it added an extra instructions also (needs to
> load the 'high' from stack before writing it) so the added delay is
> probably slightly more than just the io read.

I'm not too familiar with PCI details, but this smells a bit
like that write-combining is happening and the NIC does not like
that.

Any ideas how to check this?

The system experiencing this is a "VIA Eden 1.2Ghz" box.

Or is swapping MAC0/MAC4 writes, or adding the extra read an
acceptable fix/workaround?

- Timo
