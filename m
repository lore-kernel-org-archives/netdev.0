From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch net-next-2.6 v2] net: vlan: make non-hw-accel rx path similar to hw-accel
Date: Sun, 22 May 2011 11:24:35 -0700
Message-ID: <m1ei3qlhjw.fsf@fess.ebiederm.org>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
	<20110412.141645.112604563.davem@davemloft.net>
	<BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
	<20110521072925.GA2588@jirka.orion>
	<BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
	<4DD7BB61.9050200@gmail.com>
	<BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
	<4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion>
	<m17h9jp7js.fsf@fess.ebiederm.org>
	<BANLkTi=4JJa-J-p_JbY1PfooT75KfSB4uA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko@redhat.com>,
	Nicolas de =?utf-8?Q?Peslo=C3=BCan?=
	<nicolas.2p.debian@gmail.com>, Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52250 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752561Ab1EVSYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 14:24:45 -0400
In-Reply-To: <BANLkTi=4JJa-J-p_JbY1PfooT75KfSB4uA@mail.gmail.com> (Jesse
	Gross's message of "Sun, 22 May 2011 09:11:01 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse Gross <jesse@nicira.com> writes:

> On Sat, May 21, 2011 at 11:34 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>> Jiri Pirko <jpirko@redhat.com> writes:
>>
>>> Sun, May 22, 2011 at 04:59:49AM CEST, nicolas.2p.debian@gmail.com wrote:
>>>
>>> <snip>
>>>>
>>>>And because some setups may still require the skb not to be untagged,
>>>>may be we need the ability to re-tag the skb in some situations...
>>>>When a protocol handler or rx_handler is explicitly registered on a
>>>>net_device which expect to receive tagged skb, we should deliver
>>>>tagged skb to it... Arguably, this may sound incredible for the
>>>>general case, but may be required for not-so-special cases like
>>>>bridge or protocol analyzer.
>>>
>>> Wait, what setups/code require the skb not to be untagged? If there's
>>> such, it should be fixed.
>>
>> tcpdump on the non-vlan interface for one.
>
> There are some drivers still using the old vlan model that will drop
> tags or packets when no vlan group is configured but that's a driver
> problem, not one with networking core or tcpdump.

On receive if we have stripped the vlan header and then we go to deliver
the interrupt to a pf_packet socket (on a non-vlan interface) before
or as part of the deliver of the packet to user space we need to
re-add the vlan header.  Additionally the socket filter on a pf_packet
socket needs to behave as though we have a vlan header.

So no I am not talking about anything that is driver specific.  I am
talking about reasonable userspace expectations.  Because otherwise
we simply loose the information that a packet was vlan tagged, and
in doing so we break existing userspace applications because of our
bugs.



Eric



