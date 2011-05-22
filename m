From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch net-next-2.6 v2] net: vlan: make non-hw-accel rx path similar to hw-accel
Date: Sun, 22 May 2011 12:33:36 -0700
Message-ID: <m1r57qjzsf.fsf@fess.ebiederm.org>
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
	<m1ei3qlhjw.fsf@fess.ebiederm.org>
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
Received: from out02.mta.xmission.com ([166.70.13.232]:48667 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752237Ab1EVTdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 15:33:44 -0400
In-Reply-To: <m1ei3qlhjw.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Sun, 22 May 2011 11:24:35 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ebiederm@xmission.com (Eric W. Biederman) writes:

> Jesse Gross <jesse@nicira.com> writes:
>
>> On Sat, May 21, 2011 at 11:34 PM, Eric W. Biederman
>> <ebiederm@xmission.com> wrote:
>>> Jiri Pirko <jpirko@redhat.com> writes:
>>>
>>>> Sun, May 22, 2011 at 04:59:49AM CEST, nicolas.2p.debian@gmail.com wrote:
>>>>
>>>> <snip>
>>>>>
>>>>>And because some setups may still require the skb not to be untagged,
>>>>>may be we need the ability to re-tag the skb in some situations...
>>>>>When a protocol handler or rx_handler is explicitly registered on a
>>>>>net_device which expect to receive tagged skb, we should deliver
>>>>>tagged skb to it... Arguably, this may sound incredible for the
>>>>>general case, but may be required for not-so-special cases like
>>>>>bridge or protocol analyzer.
>>>>
>>>> Wait, what setups/code require the skb not to be untagged? If there's
>>>> such, it should be fixed.
>>>
>>> tcpdump on the non-vlan interface for one.
>>
>> There are some drivers still using the old vlan model that will drop
>> tags or packets when no vlan group is configured but that's a driver
>> problem, not one with networking core or tcpdump.
>
> On receive if we have stripped the vlan header and then we go to deliver
> the interrupt to a pf_packet socket (on a non-vlan interface) before
> or as part of the deliver of the packet to user space we need to
> re-add the vlan header.  Additionally the socket filter on a pf_packet
> socket needs to behave as though we have a vlan header.

Hmm.  Taking a second look the pf_packet code and with hardware vlan
header removal isn't completely broken.  It is possible to receive
packet auxdata and get the information from the vlan header.

It stills seems like a pretty messed up interface to me.  Especially
since the socket filter can't get at the information in the stripped
vlan header, but that is another matter entirely.

Eric
