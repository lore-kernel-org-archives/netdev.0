From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 1/2] net: dsa: integrate with SWITCHDEV for HW bridging
Date: Mon, 23 Feb 2015 10:05:41 -0800
Message-ID: <54EB6BF5.2020600@gmail.com>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com> <1424201196-4901-2-git-send-email-f.fainelli@gmail.com> <54EA8E7C.90401@roeck-us.net> <20150223031447.GA19267@lunn.ch> <54EAA767.6060105@roeck-us.net> <20150223042220.GA20063@lunn.ch> <54EAAEBC.6080609@roeck-us.net> <CAGVrzcYnuV6raXSrAETctwX5dwX3S=2-=ySewCFdx=iM7bPaDg@mail.gmail.com> <20150223133454.GB23581@lunn.ch> <54EB37C7.3090209@roeck-us.net> <20150223160109.GB27057@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	jerome.oufella@savoirfairelinux.com,
	Chris Healy <cphealy@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>, Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:42007 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751832AbbBWSGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 13:06:02 -0500
Received: by padhz1 with SMTP id hz1so29289295pad.9
        for <netdev@vger.kernel.org>; Mon, 23 Feb 2015 10:06:01 -0800 (PST)
In-Reply-To: <20150223160109.GB27057@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/02/15 08:01, Andrew Lunn wrote:
>> I currently use ATU command 110 (flush all non-static entries in a
>> particular FID). I see means to flush either all entries or all
>> non-static entries, but no means to only flush unicast or multicast
>> entries. Does any of the standards distinguish between learned unicast
>> and multicast addresses ? Flushing those selectively might be a
>> challenge.

Lucky you, on Broadcom switches you have to issue an ARL search, get the
results (there are all valid MAC entries, fortunately), and invalidate
the entries one by one for your particular ports of interest, there is
no "flush all non-static entries".

> 
> You might need to walk the table and flush records individually if you
> are only interested in one type.
> 
> We should also consider do we need to make these flush operations
> atomic with respect to other operations? Do we need to disable
> learning, flush, change the port STP status, and then enable learning?

I think we may have to do this to guarantee no race conditions between
flushing the switch's FDB, although it would look like only "joining" a
bridge needs to be a more controlled operation, on leave we can probably
just leave the bridge, flush entries and the switch port will start
learning new MAC addresses, right?

Alternatively, would not setting a very low aging timeout and
maintaining HW learning still allow us to simplify these operations?
-- 
Florian
