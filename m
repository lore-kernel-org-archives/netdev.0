From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [G[PATCH 1/2][ENETLINK] max cmd boundary chec
Date: Fri, 1 Dec 2006 15:40:58 +0100
Message-ID: <20061201144058.GG8693@postel.suug.ch>
References: <1164972613.3562.7.camel@localhost> <20061201124903.GE8693@postel.suug.ch> <1164983427.3562.36.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:5568 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S936476AbWLAOkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 09:40:37 -0500
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1164983427.3562.36.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-12-01 09:30
> Shall i assume that the patch showed up fine i.e no crap like mime?
> I still didnt get an echo back, did it make the list?
> 
> On Fri, 2006-01-12 at 13:49 +0100, Thomas Graf wrote:
> 
> > I can't see why this should be required. genl_register_ops()
> > enforces a unique command id 
> > and genl_ops->cmd is u8 so there is no way to register more than 
> > 256 commands anyway.
> 
> By mistake during the tutorial, i had the id at something like 321.
> It registered fine but then listing the command showed it with a
> different id than what i thought it should be. I think it chops off
> all the bystes other than the LS one - which is not a good error
> check.
> The compiler will whine actually. If you ignore it (perhaps not seeing
> the warning in a mass compile) it registers just fine.

There is no way to fix this in the interface. If you do u8 op = 312
and ignore the compiler warning which states that the value has been
truncated it can't be helped, the interface will see op = 56 and
register it normally. It is logically impossible to have more than 256
entries on the cmd list, the boundry check you're adding is completely
useless.
