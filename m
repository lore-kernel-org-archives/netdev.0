From: "Thomas A. Oehser" <tom@toms.net>
Subject: Re: r8169 locks up in 2.6.16.5
Date: Mon, 17 Apr 2006 20:43:58 -0400
Message-ID: <20060418004358.GA8967@jupiter.toms.net>
References: <20060415204716.GA1755@jupiter.toms.net> <20060416005821.GA9821@electric-eye.fr.zoreil.com> <20060416134201.GA2681@jupiter.toms.net> <20060416144354.GA11433@electric-eye.fr.zoreil.com> <20060416172639.GA12243@jupiter.toms.net> <20060416195327.GA14173@electric-eye.fr.zoreil.com> <20060416225843.GA2274@jupiter.toms.net> <20060417230927.GA8893@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Thomas A. Oehser" <tom@toms.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter.toms.net ([207.145.105.50]:22223 "EHLO jupiter.toms.net")
	by vger.kernel.org with ESMTP id S932091AbWDRAoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2006 20:44:02 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20060417230927.GA8893@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Thanks for the report. It is quite clear. The device is (almost surely)
> killed by a rx fifo overflow. Expect a patch shortly.
 
> I wonder why it overflows in the first place though. How much time does
> the 170 Mb transfer need ?

It is actually about a 30GB transfer, it was just after the first
170Mb that it failed.  The command in question is just a simple
"nc -l -p 12345|buffer|cpio -iumdB", and the sender may well be
able to generate the data faster than the receiving disk can save
it, as the sender is a raid-1 mirror and the receiver is a raid-5
array, I would expect the raid-5 write penalty and the raid-1 read
speed to make it have to block for most of the transfer.  It didn't
take long to get that far- um, I think only 2 or 3 minutes before
it locked up.

-Tom

-- 
May 4, 1970: Alison Krause, Jeffrey Miller, Sandra Scheuer, William Schroeder.
