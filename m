From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] VPN broken in net-next
Date: Wed, 02 Mar 2011 17:03:46 -0800 (PST)
Message-ID: <20110302.170346.13723622.davem@davemloft.net>
References: <20110302164637.6651b34f@nehalam>
	<20110302.165009.200353108.davem@davemloft.net>
	<20110302165653.4b854489@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46109
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753415Ab1CCBDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 20:03:09 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 61DC524C087
	for <netdev@vger.kernel.org>; Wed,  2 Mar 2011 17:03:46 -0800 (PST)
In-Reply-To: <20110302165653.4b854489@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 2 Mar 2011 16:56:53 -0800

> On Wed, 02 Mar 2011 16:50:09 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Stephen Hemminger <shemminger@vyatta.com>
>> Date: Wed, 2 Mar 2011 16:46:37 -0800
>> 
>> > The addresses (that matter) when VPN is up are:
>> 
>> I really need to know what addresses interfaces have the time of the
>> __ip_dev_find() call which, if I'm not mistaken, is before the VPN is
>> up.
> 
> 
>     inet 127.0.0.1/8 scope host lo
>     inet 192.168.1.11/24 brd 192.168.1.255 scope global eth0
>     inet 192.168.100.1/24 brd 192.168.100.255 scope global virbr0
>     inet 192.168.99.1/24 brd 192.168.99.255 scope global virbr1

I see nothing providing 10.0.whatever that __ip_dev_find() is being
asked to resolve.

I think we were allowing the route lookup pptp is trying to do at
connect time erroneously, and it should elide the explicit source
address specification in the flow.

See my other email.
