From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net] bnx2x: Configure device endianity on driver load
 and reset endianity on removal.
Date: Tue, 2 Sep 2014 05:47:49 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63B30338@avmb3.qlogic.org>
References: <1409581043-25357-1-git-send-email-manish.chopra@qlogic.com>
	<31AFFC7280259C4184970ABA9AFE8B93E0800207@avmb3.qlogic.org>,<20140901.145314.1237097170646182877.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: David Miller <davem@davemloft.net>,
	Manish Chopra <manish.chopra@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:52563 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750706AbaIBFrx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 01:47:53 -0400
In-Reply-To: <20140901.145314.1237097170646182877.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> This patch fixes this case from both ends:
>>> 1) Return endianity to original values on shutdown (in case little endian kernel
>>> boots after we shutdown).
>>> 2) Do not rely on HW reset values when loading driver in little endian kernel
>>>    but configure them explicitly (in case previous kernel was big endian and did
>>> not reset the HW).
 ...
>> David, Please drop this patch as it might create issue for VFs.
>> I will send updated V2 patch with proper fix.

>I think part #2 is the only reasonable part of this patch, and that's
>what you'll have to backport to -stable kernels to sort this out
>properly.

>Adding "unconfiguration" hacks into a driver to deal with driver bugs
>is really not kosher, sorry.

Why call this a hack? 
It's true #2 can solve the issue on its own for new kernels, but given the various existing distros out there (that don't include the fix) the effort of supporting those by adding #1 seems to be very small.

I wouldn't say it's not kosher; more like milchig. 

But then again, this is your domain and in truth constellations needing this fix are quite odd. If you insist we'll throw #1 away.