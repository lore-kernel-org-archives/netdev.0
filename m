From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH RFC 2/2] net: dsa: bcm_sf2: implement HW bridging operations
Date: Thu, 19 Feb 2015 18:51:06 -0800
Message-ID: <54E6A11A.2060703@cumulusnetworks.com>
References: <1424201196-4901-3-git-send-email-f.fainelli@gmail.com> <54E54EF3.9020802@gmail.com> <20150219055953.GA14247@roeck-us.net> <54E61CFB.3010109@gmail.com> <20150219174640.GA6897@roeck-us.net> <54E676DD.9090003@gmail.com> <20150220000935.GA30118@roeck-us.net> <54E68512.6070108@cumulusnetworks.com> <20150220010352.GA300@roeck-us.net> <54E691F2.5090205@cumulusnetworks.com> <20150220021843.GG795@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, cphealy@gmail.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:34549 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752711AbbBTCvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 21:51:10 -0500
Received: by pdjg10 with SMTP id g10so4423117pdj.1
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 18:51:09 -0800 (PST)
In-Reply-To: <20150220021843.GG795@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/19/15, 6:18 PM, Andrew Lunn wrote:
>>> Remember that we are dealing with hardware switch chips. Those chips
>>> won't time out fdb entries just because the kernel's bridge driver
>>> thinks that it should.
>> Oh, they dont..?
> To some extent, it is better to think of these as two switches
> connected to each other, not one switch. The HW switch needs help with
> STP, but otherwise it is a fully functional and autonomous switch.
yes, exactly.
>
> This is going to make displaying the forwarding database interesting,
> because the SW bridge fdb and the HW bridge fdb are each subsets of
> the big picture and possible even contradictory since they are not
> updated atomically.
>
What we do on our switches is,
- disable SW bridge learning
- enable HW bridge learning
- we keep the SW bridge fdb in sync with the HW fdb, which leads to:
         - HW learnt entries are pushed to SW bridge fdb
         - SW static fdb entries (added by the user) are pushed to HW
