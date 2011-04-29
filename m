From: Einar EL Lueck <ELELUECK@de.ibm.com>
Subject: Re: oops during unregister_netdevice interface enslaved to bond -
	regression
Date: Fri, 29 Apr 2011 16:45:45 +0200
Message-ID: <OF46D78C46.5B4BE29C-ONC1257881.0050BB22-C1257881.00511537@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Frank Blaschka <Frank.Blaschka@de.ibm.com>
To: opurdila@ixiacom.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([194.196.100.166]:54194 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755602Ab1D2Opp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 10:45:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Octavian,

On 04/15/2011 10:53 AM, Frank Blaschka wrote:
> Hi Octavian,
>
> your commit 443457242beb6716b43db4d62fe148eab5515505 introduced this
regression.
> I have reviewed the net device unregister code but did not understand it
very well.
> I have seen the problem only in combination with bonding. Can you give me
some help
> how to go on with this problem. I can reproduced it very easy on a single
CPU
> machine.
>

In this case rollback_registered_many iterates over the list of devs that
initially has just one device in it. In a loop it calls
call_netdevice_notifiers(NETDEV_UNREGISTER, dev) which triggers the bonding
driver to call dev_close_many for the same device. That call to
dev_close_many leads to the addition of the same device to the list over
which rollback_registered_many is iterating. Consequently,
netdev_unregister_kobject(dev) is called twice for the same device. Frank
captured the result in his mail.

Do you agree with my debugging results?

Regards,
Einar.

