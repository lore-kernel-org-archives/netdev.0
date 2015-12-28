From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCHv2 net-next 0/3] Ethtool support for phy stats
Date: Mon, 28 Dec 2015 09:27:25 -0800
Message-ID: <ACCDAA4E-5186-4920-BC1E-4A5D4D55F4EE@gmail.com>
References: <1451217508-22276-1-git-send-email-andrew@lunn.ch> <20151228.003243.762236700442924187.davem@davemloft.net> <20151228.004427.1444978630699405304.davem@davemloft.net> <20151228085825.GA30297@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:34916 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbbL1Rut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2015 12:50:49 -0500
Received: by mail-ob0-f170.google.com with SMTP id 18so238119341obc.2
        for <netdev@vger.kernel.org>; Mon, 28 Dec 2015 09:50:49 -0800 (PST)
In-Reply-To: <20151228085825.GA30297@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On December 28, 2015 12:58:25 AM PST, Andrew Lunn <andrew@lunn.ch> wrote:
>On Mon, Dec 28, 2015 at 12:44:27AM -0500, David Miller wrote:
>> From: David Miller <davem@davemloft.net>
>> Date: Mon, 28 Dec 2015 00:32:43 -0500 (EST)
>> 
>> > From: Andrew Lunn <andrew@lunn.ch>
>> > Date: Sun, 27 Dec 2015 12:58:25 +0100
>> > 
>> >> This patchset add ethtool support for reading statistics from the
>PHY.
>> >> The Marvell and Micrel Phys are then extended to report receiver
>> >> packet errors and idle errors.
>> >> 
>> >> v2:
>> >>   Fix linking when phylib is not enabled.
>> > 
>> > Series applied, thanks Andrew.
>> 
>> I have to revert this.
>> 
>> You can't call into PHY library code from net/core/ethtool.c,
>> because PHY lib can be modular.
>
>O.K.
>
>How about we change PHYLIB from a tristate to a bool?

Could we make this in a two layer design instead? Core ethtool changes call into getter functions which are implemented by the netdev driver, if the netdev driver happens to use PHYLIB, calls into the PHYLIB helpers with its phydev? That would also allow a network driver already supporting PHY stats to report them through your new interface.

-- 
Florian
