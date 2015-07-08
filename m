From: Sowmini Varadhan <sowmini05@gmail.com>
Subject: Re: [RFC net-next 3/6] net: Introduce VRF device driver - v2
Date: Wed, 8 Jul 2015 20:34:09 +0200
Message-ID: <CACP96tTyw+J7swi-+GJMwKKVjE9Uk1dJ3m_JKg2o1tyZup+p0w@mail.gmail.com>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>
	<1436195001-4818-4-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, shm@cumulusnetworks.com,
	roopa@cumulusnetworks.com,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	ddutt@cumulusnetworks.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	hadi@mojatatu.com, "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:35883 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758299AbbGHSeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 14:34:11 -0400
Received: by wgxm20 with SMTP id m20so20202789wgx.3
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 11:34:09 -0700 (PDT)
In-Reply-To: <1436195001-4818-4-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 6, 2015 at 5:03 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> This driver borrows heavily from IPvlan and teaming drivers.
>
> Routing domains (VRF-lite) are created by instantiating a device
> and enslaving all routed interfaces that participate in the domain.
> As part of the enslavement, all local routes pointing to enslaved
> devices are re-pointed to the vrf device, thus forcing outgoing
> sockets to bind to the vrf to function.
>
> Standard FIB rules can then bind the VRF device to tables and regular
> fib rule processing is followed.

Perhaps I misunderstand the design proposal here, but a switch's VRF
is essentially just a separate routing table, whose input and output interfaces
are exclusively bound to the VRF.

Can an application in the model above get visibiltiy into the (enslaved?)
interfaces in the vrf? Can an application use IP_PKTINFO to send a packet out of
a specific interface on a selected VRF? What about receiving
IP_PKTINFO about input interface?
What about setting ipsec policy for interfaces in the vrf?

> Routed traffic through the box, is fwded by using the VRF device as
> the IIF and following the IIF rule to a table which is mated with
> the VRF.
>
> Locally originated traffic is directed at the VRF device using
> SO_BINDTODEVICE or cmsg headers. This in turn drops the packet into
> the xmit function of the vrf driver, which then completes the ip lookup
> and output.
>
> This solution is completely orthogonal to namespaces and allow the L3
> equivalent of vlans to exist allowing the routing space to be
> partitioned.
