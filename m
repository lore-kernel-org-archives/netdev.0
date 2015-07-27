From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [net-next 0/16] Proposal for VRF-lite - v3
Date: Mon, 27 Jul 2015 15:30:48 -0500
Message-ID: <87egjtz6kn.fsf@x220.int.ebiederm.org>
References: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	ddutt@cumulusnetworks.com, hannes@stressinduktion.org,
	nicolas.dichtel@6wind.com, stephen@networkplumber.org,
	hadi@mojatatu.com, davem@davemloft.net, svaidya@brocade.com,
	mingo@kernel.org, luto@amacapital.net
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:58699 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915AbbG0UhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 16:37:25 -0400
In-Reply-To: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
	(David Ahern's message of "Mon, 27 Jul 2015 12:30:53 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsa@cumulusnetworks.com> writes:

> In the context of internet scale routing a requirement that always comes
> up is the need to partition the available routing tables into disjoint
> routing planes. A specific use case is the multi-tenancy problem where
> each tenant has their own unique routing tables and in the very least
> need different default gateways.
>
> This patch allows the ability to create virtual router domains (aka VRFs
> (VRF-lite to be specific) in the linux packet forwarding stack. The main
> observation is that through the use of rules and socket binding to interfaces,
> all the facilities that we need are already present in the infrastructure. What
> is missing is a handle that identifies a routing domain and can be used to
> gather applicable rules/tables and uniqify neighbor selection. The scheme used
> needs to preserves the notions of ECMP, and general routing
> principles.

This paragraph is false when it comes to sockets, as I have already
pointed out.

- VPN Routing and Forwarding (RFC4364 and it's kin) implies isolation
  strong enough to allow using the the same ip on different machines
  in different VPN instances and not have confusion.

- The routing table is not the only table in the kernel that uses
  an ip address as a key.

  The result is that you can combine packets fragments that come in
  on different interfaces (irrespective of your VPN), confuse tcp
  parameters between interfaces, scramble your ipsec connections and I
  don't know what else.

Binding a socket to a network device is not strong enough to do what you
want to do and it will lead to subtle bugs, that can be triggered by
accident or by hostile actors.

If these kinds of limitations are well documented and it is specified
that these kinds of problems can occur with your socket code there may
be a place for this code somewhere.

However described like it is your code is wrong and fundmentally broken.
>
> Version 3
> - addressed comments from first 2 RFCs with the exception of the name
>   Nicolas: We will do the name conversion once we agree on what the
>            correct name should be (vrf, mrf or something else)

Not so.  I described the deep problems between your goals and your
implementation and they are not even mentioned let alone addressed.

> -  packets flow through the VRF device in both directions allowing the
>    following:
>    - tcpdump -i vrf<n>
>    - tc rules on vrf device
>    - netfilter rules on vrf device
>
> Ingo/Andy: I added you two as a start point for the proposed task related
>            changes. Not sure who should be the reviewer; please let me know
>            if someone else is more appropriate. Thanks.

It looks like you are trying to implement a namespace that isn't a
namespace.  Given that it is broken by design you have my nack.

Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Eric
