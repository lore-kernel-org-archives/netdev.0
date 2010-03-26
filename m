From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/3] ixgbe: In SR-IOV mode insert delay before
 bring the adapter up
Date: Fri, 26 Mar 2010 11:57:53 -0700 (PDT)
Message-ID: <20100326.115753.160228163.davem@davemloft.net>
References: <20100324193515.6078.27035.stgit@localhost.localdomain>
	<20100324193608.6078.61157.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50457
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751246Ab0CZS53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 14:57:29 -0400
In-Reply-To: <20100324193608.6078.61157.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 24 Mar 2010 12:36:08 -0700

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> VFs running in guest VMs do not respond in as timely a manner to
> PF indication it is going down as they do when running in the host
> domain.  If the adapter is in SR-IOV mode insert a two second delay
> to guarantee that all VFs have had time to respond to the PF reset.
> In any case resetting the PF while VFs are active should be
> discouraged but if it must be done then there will be a two
> second delay to help synchronize resets among the PF and all the
> VFs.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, but...

I know why you might need to do this, but this is going to completely
explode if someone tries to, f.e. bring up thousands of these
interfaces.

Maybe that's not practical, but is, say, 30?  With a 2 second delay
each that's a full minute hanging at the command line or the bootup
scripts.

My point is that this behavior is basically extremely undesirable.
