From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH RFC 1/2] net: dsa: integrate with SWITCHDEV for HW bridging
Date: Mon, 23 Feb 2015 06:23:03 -0800
Message-ID: <54EB37C7.3090209@roeck-us.net>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com> <1424201196-4901-2-git-send-email-f.fainelli@gmail.com> <54EA8E7C.90401@roeck-us.net> <20150223031447.GA19267@lunn.ch> <54EAA767.6060105@roeck-us.net> <20150223042220.GA20063@lunn.ch> <54EAAEBC.6080609@roeck-us.net> <CAGVrzcYnuV6raXSrAETctwX5dwX3S=2-=ySewCFdx=iM7bPaDg@mail.gmail.com> <20150223133454.GB23581@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	jerome.oufella@savoirfairelinux.com,
	Chris Healy <cphealy@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:52024 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055AbbBWOXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 09:23:40 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YPtv9-0002Di-QB
	for netdev@vger.kernel.org; Mon, 23 Feb 2015 14:23:39 +0000
In-Reply-To: <20150223133454.GB23581@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/23/2015 05:34 AM, Andrew Lunn wrote:
>> BTW, before I re-submit this patch series, do you think we should
>> introduce a fdb_flush() callback that switch drivers are required to
>> implement, and invoke it from net/dsa/slave.c upon port join/leave?
>
> Probably a good idea.
>
> We should define exactly what is flushed. Everything? Or only dynamic
> entries? The Marvell hardware can also have multicast addresses in its
> tables, which can age, or static unicast and multicast entries.
>

I currently use ATU command 110 (flush all non-static entries in a
particular FID). I see means to flush either all entries or all
non-static entries, but no means to only flush unicast or multicast
entries. Does any of the standards distinguish between learned unicast
and multicast addresses ? Flushing those selectively might be a
challenge.

Guenter
