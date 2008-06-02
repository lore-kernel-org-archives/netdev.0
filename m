From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [PATCH RFC] net/bonding: announce fail-over for the active-backup
 mode
Date: Mon, 02 Jun 2008 13:39:52 +0300
Message-ID: <4843CDF8.5010200@voltaire.com>
References: <Pine.LNX.4.64.0805211550060.27300@zuben.voltaire.com> <Pine.LNX.4.64.0805271012220.18192@zuben.voltaire.com> <12513.1212013148@death> <483E847A.9090508@voltaire.com> <28012.1212131745@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:14856 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758225AbYFBKj5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2008 06:39:57 -0400
In-Reply-To: <28012.1212131745@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> 	I'm suggesting you do exactly that: release the locks, do your
> stuff, then reacquire the locks.
OK
> 	I took a look, and I think this is how it stands: I recently
> refactored the active-backup ARP monitor, and I believe that all of its
> calls are now correct; this would have been the difficult one to fix, so
> you timed this just right.  The load-balance ARP monitor is still wrong,
> but you don't care about that one since it isn't used for active-backup
> mode.
sounds like I am lucky.
> 	I think the only cases that will require fixing for you are the
> bond_release and bond_release_all.
>
> 	For bond_release, there are two calls to change_active: one sets
> it to NULL, and the second sets to to a slave.  The first of those calls
> has nominally incorrect locking; the second has proper locking.
> Changing the first call to mimic the methodology of the second call
> should be pretty straightforward.  Alternately, if your notifier doesn't
> want to log "change to nothing" events (i.e., put it inside the "if
> (new_active)" block), then you could probably get away with not fixing
> the first call.
>
> 	For bond_release_all, there's just one call, and it sets the
> current slave to NULL (and then goes off and frees all of the slaves).
> The same caveats from the bond_release case apply here.

Thanks for this deep dive and guidance. I don't think there's a need to 
deliver "change to nothing" event and as such I took the approach of 
setting this event to happen only (under the acrtive-backup mode AND) 
when new_active is not NULL, will send now the patches which I tested today.

Or.

