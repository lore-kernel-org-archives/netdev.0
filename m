From: Brian Haley <brian.haley@hp.com>
Subject: Re: MACVLANs really best solution? How about a bridge with multiple
 bridge virtual interfaces?
Date: Mon, 09 Mar 2009 14:33:28 -0400
Message-ID: <49B560F8.4090602@hp.com>
References: <20090307211527.6e76d0b9.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>	<49B51A42.6050507@trash.net> <m11vt6d9t6.fsf@fess.ebiederm.org>	<49B52F73.7010508@trash.net> <m13admbsuk.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Mark Smith
	<nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>,
	greearb@candelatech.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, shemminger@linux-foundation.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:3083 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753793AbZCISdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 14:33:33 -0400
In-Reply-To: <m13admbsuk.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> There are two tricky parts.
> 
> One problem is that macvlans and the primary hardware device share the
> same transmit queue.  So when I have a broadcast packet on the primary
> devices queue I don't know if I have already sent it out to the
> macvlan devices or not.
> 
> The second problem is that when I transmit a multicast packet and I
> have a local listener.  I believe replicating the packet both at the
> ip layer and at the ethernet layer will result in receiving the packet
> locally twice.

If you want a local listener to see the packet you have to set
IP_MULTICAST_LOOP.  A packet from a local source address coming off the "wire"
will be dropped in fib_validate_source(), it would have to come over lo.  I'm
not sure how that relates to how macvlan works, just something I've run into
before (2 nics in same subnet, listener on one, sender on other,
IP_MULTICAST_LOOP=0, no packets).

-Brian
