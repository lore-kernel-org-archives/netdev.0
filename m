From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: make CONFIG_BQL actually end user configurable
Date: Mon, 5 Mar 2012 21:57:40 -0800
Message-ID: <CA+mtBx9kZc+Ovrohbffxe=be6zehNneCXQsH7HrgYELmtfLptA@mail.gmail.com>
References: <1331005096-12332-1-git-send-email-paul.gortmaker@windriver.com>
	<CAA93jw5HadpvBvtZvf6ArK3tdm=7Cs9sLYeHO9WN6rJOfPLPbA@mail.gmail.com>
	<20120306040921.GA24032@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Taht <dave.taht@gmail.com>, davem@davemloft.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:43167 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881Ab2CFF5k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 00:57:40 -0500
Received: by iagz16 with SMTP id z16so6591651iag.19
        for <netdev@vger.kernel.org>; Mon, 05 Mar 2012 21:57:40 -0800 (PST)
In-Reply-To: <20120306040921.GA24032@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> 1) There is no way to tell if a driver has it actually enabled or no=
t
>> at run time.
>
> In a similar vein, I was interested in a (quick) way to tell if a
> driver has it actually enabled *correctly*. =A0I'd coded up the basic
> changes for a common PPC NIC, but I was then left wondering what I
> could use as a quick high-water-mark to see if I'd really managed
> to implement it correctly via some level of real run-time testing.
>
The sysfs variables should be good to view the operation and effects
of BQL.  To disable BQL (at least limit checking) "echo max >
limit_min" should be sufficient.

It is true there is no way to determine that BQL is implement for a
device, the sysfs variables are always created.  If it is
unimplemented then inflight and limit variables are always zero.

> If we want to get driver authors involved in adding support to their
> favourite hardware, some description of a basic sanity test would
> probably be a worthwhile description to have.

That would be good.  The best window into BQL is the sysfs variables
(inflight and limit).  Setting zero or max to limit_min should impact
the number of queued bytes being reported.  ("watch cat *" in tx-0I'm
still intending to get the document on BQL out, the sanity check would
be good to describe there I think.

Thanks,
Tom
