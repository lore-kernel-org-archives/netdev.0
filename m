From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next-2.6 v4] bonding: allow arp_ip_targets on
	separate vlans to use arp validation
Date: Mon, 28 Dec 2009 19:51:45 -0500
Message-ID: <20091229005145.GB6490@gospo.rdu.redhat.com>
References: <20091214204858.GP1639@gospo.rdu.redhat.com> <20091225.182230.183058983.davem@davemloft.net> <20091228152632.GA6490@gospo.rdu.redhat.com> <20091228.073308.112591206.davem@davemloft.net> <13580.1262037333@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, andy@greyhouse.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23015 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751088AbZL2Av4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Dec 2009 19:51:56 -0500
Content-Disposition: inline
In-Reply-To: <13580.1262037333@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 28, 2009 at 01:55:33PM -0800, Jay Vosburgh wrote:
> David Miller <davem@davemloft.net> wrote:
> 
> >From: Andy Gospodarek <andy@greyhouse.net>
> >Date: Mon, 28 Dec 2009 10:26:32 -0500
> >
> >> This patch should be ready for inclusion.
> >
> >Yes, but I haven't seen ACK's from Jay or Eric.
> 
> 	I was testing with the final patch just before my personal
> holiday adventures began, and was having one problem: the ARP monitor
> part worked fine on the VLAN (the slaves were up) but regular traffic on
> that same VLAN, e.g., ping, was dropped on receive at the bond.  The
> peer (without bonding) saw the traffic, and responded, but it appeared
> that ARP replies from the peer (again, over the VLAN) weren't making it
> to the ARP table (at the bond end), so everything that depended on the
> ARP table wasn't working.
> 
> 	I'm willing to believe this is a personal problem at my end, but
> I haven't determined the cause, and won't have the opportunity until
> next week (after my house has drained of relatives).
> 
> 	If Andy isn't seeing the above misbehavior, I'm fine with
> assuming it's my problem and applying the patch; if I find something
> actually wrong with the patch next week we can address it then.
> 

>From time to time, I would see something similar would be if I was
testing without VLANs and ended up with a stale entry in the remote
hosts ARP table that would cause the response traffic to get sent
without a VLAN tag.

I was able to pass tagged traffic when the bond was up and always made
sure to scp my tested patches over that link to the machine that would
post them.  It seems like good practice to exercise the changes I'm
making during the posting process. :)

