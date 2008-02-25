From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: Re: [PATCH] tg3: ethtool phys_id default (rev2)
Date: Mon, 25 Feb 2008 18:13:00 +0200
Message-ID: <1203955980.8232.227.camel@lb-tlvb-eliezer.il.broadcom.com>
References: <20080222102429.7e48f1f1@extreme>
 <1203707802.13495.169.camel@dell>
 <20080223.195221.177613282.davem@davemloft.net>
 <1203831726.8232.115.camel@lb-tlvb-eliezer.il.broadcom.com>
 <20080225075814.577b3eb6@extreme>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, mchan@broadcom.com,
	jgarzik@pobox.com, netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1071 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750838AbYBYQNT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 11:13:19 -0500
In-Reply-To: <20080225075814.577b3eb6@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Doesn't this mean that ethtool -p will hold the RTNL lock forever?
> > Is this a good idea?
> > 
> > For example on the Red Hat machine I have here if you do:
> > 
> > ethtool -p eth2 100000 &
> > reboot
> > 
> > Various things the shutdown scripts try to do will fail because of the
> > held RTNL lock. in the end the script dies and the machine does not
> > reboot.
> 
> 1. ethtool -p is only used by root to identify interfaces, so in practice
>    this is not a real problem.
> 
> 2. ethtool -p is interruptible, and the reboot process sends a SIGTERM to
>    all processes.


The simple use-case of running ethtool -p eth0 10000 on an ssh console
and them going to the rack and pressing the power button fails.

It seems like the shutdown script dies a long way before it usually
kills all the processes. 

Bringing down NFS, SNMP and several other services fails.
Then things die for being blocked more then 120 seconds and the system
is stuck.




