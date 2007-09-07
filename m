From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/1] ipv6: corrects sended rtnetlink message
Date: Fri, 7 Sep 2007 12:11:38 +0200
Message-ID: <20070907101137.GX18480@postel.suug.ch>
References: <20070815143322.GA25640@wq.cz> <20070821.002058.102575162.davem@davemloft.net> <20070829215119.GB15856@wq.cz> <20070906104711.GV18480@postel.suug.ch> <20070906210550.GA13542@wq.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Milan Kocian <milon@wq.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:45085 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964945AbXIGKLR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 06:11:17 -0400
Content-Disposition: inline
In-Reply-To: <20070906210550.GA13542@wq.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Milan Kocian <milon@wq.cz> 2007-09-06 23:05
> I agree but ipv6 sends on device change (NETDEV_DOWN) RTM_DELLINK message.
> BTW when ipv6 send LINK message on NETDEV_UNREGISTER event, why doesn't 
> send message on NETDEV_REGISTER event? No symmetry ?

You should be seeing two RTM_DELLINK upon NETDEV_UNREGISTER if the
interface carried any IPv6 addresess. Once with ifi_change=~0
notifying you that the device is disappearing and once with
ifi_change=0 coming from the IPv6 protocol shutdown.

> ok. However, if I understand, LINK messages handle device changes not
> protocol changes. Or not ?

Yes, I personally think this behaviour is wrong but we can't remove it
unless we are sure it doesn't break anything.

> Now I ignore (RTM_DELLINK && ifi_family==AF_INET6) :-). But it's only workaround
> till next change. 

That's also correct, pure netdevice notification will always be sent
with the ifi_family set to AF_UNSPEC.

> Hard to find it. I can try to look at other routing sw (probably most using it)
> about handling with RTM_DELLINK.
> Howerer when was made change from RTM_NEWLINK to RTM_DELLINK without protests,
> we can try remove message :-)

I'd give the USAGI software tree a short peek, if there was a specific
reason for adding this notification in the first place, the software is
most probably found in that tree.
