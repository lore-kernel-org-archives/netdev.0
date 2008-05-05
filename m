From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] Re: [PATCH 01/13] QLogic VNIC: Driver - netdev implementation
Date: Mon, 05 May 2008 13:42:15 -0700
Message-ID: <adafxsw1o0o.fsf@cisco.com>
References: <20080430171028.31725.86190.stgit@localhost.localdomain>
	<20080430171624.31725.98475.stgit@localhost.localdomain>
	<adaiqxw4lox.fsf@cisco.com>
	<71d336490805050836o68d745f2k4bab68edcfe1da50@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, poornima.kamath@qlogic.com,
	general@lists.openfabrics.org, amar.mudrankit@qlogic.com
To: "Ramachandra K" <ramachandra.kuchimanchi@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:44266 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297AbYEEUmW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 16:42:22 -0400
In-Reply-To: <71d336490805050836o68d745f2k4bab68edcfe1da50@mail.gmail.com>
	(Ramachandra K.'s message of "Mon, 5 May 2008 21:06:58 +0530")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > I will make sure to sign off on all patches. Should I also drop the From line
 > for the patches which I developed, since I am mailing them myself ?

It doesn't hurt to include a From: line if it is the same as the one for
the email itself, but it isn't necessary.  When I import a patch the
last From: line will be used.

 > I am using the Signed-off-by line to indicate the people who were
 > involved in the development of the patches at some stage.

That's fine.  You can read Documentation/SubmittingPatches to see the
precise legal meaning of Signed-off-by, and make sure that it applies to
everyone whose signoff you are including.  You can also add less formal
text like "X <z@foo> helped develop this patch" in the changelog entry.

 > >   > +extern cycles_t recv_ref;
 > >
 > >  seems like too generic a name to make global.  What the heck are you
 > >  using cycle_t to keep track of anyway?
 > >
 > 
 > This is being used as part of the driver internal statistics
 > collection to keep track of the time
 > elapsed between a message arriving from the EVIC indicating that it
 > has done an RDMA write of
 > an Ethernet packet to the driver memory and the driver giving the packet
 > to the network stack.

cycles don't track time (eg x86 TSC might stop for a while).  Do you
*really* need to use cycles, or are jiffies a better replacement?

 - R.
