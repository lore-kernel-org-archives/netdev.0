From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next-2.6 1/2] bonding: add keep_all parameter
Date: Tue, 11 May 2010 14:17:57 -0400
Message-ID: <20100511181757.GA14545@hmsreliant.think-freely.org>
References: <20100511002949.GA7497@gospo.rdu.redhat.com>
 <7958.1273598301@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36814 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756972Ab0EKSSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 14:18:04 -0400
Content-Disposition: inline
In-Reply-To: <7958.1273598301@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 11, 2010 at 10:18:21AM -0700, Jay Vosburgh wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> 
> >
> >In an effort to suppress duplicate frames on certain bonding modes
> >(specifically the modes that do not require additional configuration on
> >the switch or switches connected to the host),
> 
> 	Strictly speaking, the above is incorrect, as the duplicate
> suppression is turned on for the active-backup inactive slaves as well
> as 802.3ad ports that are disabled (any slave that gets the "inactive"
> flag bit set).
> 
> >[...] code was added in the
> >generic receive patch in 2.6.16.  The current behavior works quite well
> >for most users, but there are some times it would be nice to restore old
> >functionality and allow all frames to make their way up the stack.
> 
> 	Reading netdev lately, it sure looks like everybody wants ways
> to shut off or bypass the duplicate suppression.
> 
> >This patch adds support for a new module option and sysfs file called
> >'keep_all' that will restore pre-2.6.16 functionality if the user
> >desires.  The default value is '0' and retains existing behavior, but
> >the user can set it to '1' and allow all frames up if desired.
> 
> 	Since this is really meant for the queue tagging stuff in the
> next patch, should this really be something that's enabled automatically
> if the queues are configured in such a way that the inactive slave is
> going to receive traffic?
> 
I agree that it might be usefull to have this on by default, we can't really
know if the queues are going to be setup to direct traffic to inactive slaves
until after the module is loaded and the interface is created.  Setting up tc
filters to steer traffic will only occur after the interface is other wise
configured (bond needs to be created, and slaves need to be added).  Perhaps
user space could tie the the setting of this variable in sysfs to tc
configuration in some way?

Neil

