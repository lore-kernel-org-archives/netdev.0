From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: dhcp/bonding interaction question
Date: Tue, 23 Sep 2008 18:15:38 -0600
Message-ID: <48D986AA.6030400@nortel.com>
References: <48D90A30.8000701@nortel.com> <6323.1222188151@death.nxdomain.ibm.com> <48D924A5.4070701@nortel.com> <21694.1222193834@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kn.nortel.com ([47.140.192.55]:50352 "EHLO
	zrtps0kn.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462AbYIXAQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 20:16:12 -0400
In-Reply-To: <21694.1222193834@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> Chris Friesen <cfriesen@nortel.com> wrote:
> 	Ok, so your problem (if I'm understanding things correctly) is
> really a chicken-and-egg type of deal.  Your entire network is all
> etherchannel, except for this blade, which needs to connect,
> temporarily, in a non-etherchannel manner in order to boot up and become
> etherchannel-ified (at which point it'll work).

Basically, yes.

> 	One possible problem with hacking the dhcpd to send back out on
> the receiving interface is that (because of the etherchannel) there's no
> general guarantee that the switch paths are symmetrical, particularly if
> a port is down somewhere.

True.

> 	If you're already rolling your own kernels, would it be easier
> to remove the xid interface check from the kernel's dhcp client (i.e.,
> accept the DHCP reply as if it had arrived on the proper interface for
> its xid)?  You could make it into some kind of "netboot_on_etherchannel"
> option.

Yes, this is being considered as well.  Initially I was against it due 
to the possibility of introducing unexpected behaviour, but making it a 
boot argument makes a lot of sense, especially since it would allow for 
more robust behaviour on certain fault scenarios.

Thanks,

Chris
