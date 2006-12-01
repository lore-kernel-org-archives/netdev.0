From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [G[PATCH 1/2][ENETLINK] max cmd boundary chec
Date: Fri, 1 Dec 2006 16:16:57 +0100
Message-ID: <20061201151657.GH8693@postel.suug.ch>
References: <1164972613.3562.7.camel@localhost> <20061201124903.GE8693@postel.suug.ch> <1164983427.3562.36.camel@localhost> <20061201144058.GG8693@postel.suug.ch> <1164984758.3562.57.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:36032 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S935044AbWLAPQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 10:16:36 -0500
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1164984758.3562.57.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-12-01 09:52
> You cannot have more than 256 commands because 0x138 and 0x38 are
> treated as the same command. So does 0x238, 0x1138...
> It is useless/unneeded if the register ops will always see the chopped
> value. Is this so?

The interface enforces a proper value by the type it accepts which
is certainly more desireable than a runtime error. If you happen
to ignore compiler warnings, then maybe there is the problem. Despite
of all this, the patch you propose doesn't work anyway.

If you really want a runtime error you have to change the cmd field
in genl_ops to be of larger size and then just check > MAX_ARGS in
register_ops() rather than making get_cmd() more expensive which
is called for every message received. I don't see any reason why
this should be better than a compile warning.
