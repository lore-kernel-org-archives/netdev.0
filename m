From: Patrick McHardy <kaber@trash.net>
Subject: Re: MACVLANs really best solution? How about a bridge with multiple
 bridge virtual interfaces?
Date: Mon, 09 Mar 2009 16:53:16 +0100
Message-ID: <49B53B6C.7060400@trash.net>
References: <20090307211527.6e76d0b9.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>	<49B51A42.6050507@trash.net> <m11vt6d9t6.fsf@fess.ebiederm.org>	<49B52F73.7010508@trash.net> <m13admbsuk.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Smith
	<nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>,
	greearb@candelatech.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, shemminger@linux-foundation.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47726 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751326AbZCIPxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 11:53:22 -0400
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

So its about receiving packets on macvlan when transmitting on the
real device? That sounds like a really hard problem that would probably
indeed be better solved by a bridge.

If its just about whether the packet should be sent out by macvlan
to the wire as well, I'd say yes since thats what two real devices
would have done.

> The second problem is that when I transmit a multicast packet and I
> have a local listener.  I believe replicating the packet both at the
> ip layer and at the ethernet layer will result in receiving the packet
> locally twice.
> 
> I'm not certain we need to solve the second problem as having two physical
> interfaces plugged into a switch will have the same problem.

Agreed.

> The first problem is all about how do we deliver packets everywhere except self.

I think "except self should just mean "not to the originating virtual
device".
