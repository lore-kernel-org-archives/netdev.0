From: Einar EL Lueck <ELELUECK@de.ibm.com>
Subject: Fw: oops during unregister_netdevice interface enslaved to bond -
	regression
Date: Tue, 10 May 2011 10:17:09 +0200
Message-ID: <OF0F4919C3.B9CFCAE8-ONC125788C.002D5EB1-C125788C.002D83B7@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, Frank Blaschka <Frank.Blaschka@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([194.196.100.162]:41673 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753047Ab1EJIRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 04:17:13 -0400
Received: from d06nrmr1307.portsmouth.uk.ibm.com (d06nrmr1307.portsmouth.uk.ibm.com [9.149.38.129])
	by mtagate2.uk.ibm.com (8.13.1/8.13.1) with ESMTP id p4A8HCoE020827
	for <netdev@vger.kernel.org>; Tue, 10 May 2011 08:17:12 GMT
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by d06nrmr1307.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4A8HBEs2428994
	for <netdev@vger.kernel.org>; Tue, 10 May 2011 09:17:11 +0100
Received: from d06av09.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4A8HAxr010539
	for <netdev@vger.kernel.org>; Tue, 10 May 2011 02:17:10 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Dave,

Einar EL Lueck/Germany/IBM wrote on 04/29/2011 04:45:45 PM:

> From:
>
> Einar EL Lueck/Germany/IBM
>
> To:
>
> opurdila@ixiacom.com, netdev@vger.kernel.org, linux-
> s390@vger.kernel.org, davem@davemloft.net
>
> Cc:
>
> Frank Blaschka/Germany/IBM@IBMDE
>
> Date:
>
> 04/29/2011 04:45 PM
>
> Subject:
>
> Re: oops during unregister_netdevice interface enslaved to bond -
regression
>
> Hi Octavian,
>
> On 04/15/2011 10:53 AM, Frank Blaschka wrote:
> > Hi Octavian,
> >
> > your commit 443457242beb6716b43db4d62fe148eab5515505 introduced
> this regression.
> > I have reviewed the net device unregister code but did not
> understand it very well.
> > I have seen the problem only in combination with bonding. Can you
> give me some help
> > how to go on with this problem. I can reproduced it very easy on
asingle CPU
> > machine.
> >
>
> In this case rollback_registered_many iterates over the list of devs
> that initially has just one device in it. In a loop it calls
> call_netdevice_notifiers(NETDEV_UNREGISTER, dev) which triggers the
> bonding driver to call dev_close_many for the same device. That call
> to dev_close_many leads to the addition of the same device to the
> list over which rollback_registered_many is iterating. Consequently,
> netdev_unregister_kobject(dev) is called twice for the same device.
> Frank captured the result in his mail.
>

Calls to the *_many functions introduced by Octavian may never interleave
because
the traversed lists modify each other. This was the root cause for the
symptom that Frank discovered. Octavian is not a valid mail recipient
anymore and did not react from any new mail address. I suggest to revert
the commit.

Regards,
Einar.

