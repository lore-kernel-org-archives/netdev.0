From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCHv3 net-next 2/3] sunvnet: allow admin to set sunvnet MTU
Date: Sun, 14 Sep 2014 09:24:16 -0400
Message-ID: <54159700.3030002@oracle.com>
References: <54146A37.5010108@oracle.com> <20140913.162101.515634682549373073.davem@davemloft.net> <5414FA4D.6030504@oracle.com> <54158835.8000508@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24353 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752594AbaINNYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2014 09:24:22 -0400
In-Reply-To: <54158835.8000508@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/14/2014 08:21 AM, Sowmini Varadhan wrote:

> To put things in perspective, in practice its only legacy linux today that will do the v1.0, and administrators are likely to want to upgrade
> to the later version, so encumbering the code with legacy version support may end up becoming hard-to-maintain code?

No, v1.8 Solaris would force us to a 1/3 drop in performance between linux LDOMs because of its 16000 byte MTU limit.
I don't think it's particularly hard to maintain -- it's virtually a literal translation of the text in the VIO protocol
document. Everything that's there should stay there; only new revisions of the protocol would cause new changes, presumably
in other areas of the code where those new features are implemented. And I don't think reverse compatibility is optional.

> As I understand it, this method of sending ICMP from the driver will not
> work for L2 (non-IP) packets, and it will not even work for IP packets that are coming to us, from, say, openvswitch, right? So in practice it
> actually has limited usability?

It wouldn't work for a bridged L2 network with no local IP address, because there would be no valid return IP address for the
ICMP error we generate (in IPv4 -- IPv6 will always have a valid link-local address). Everything else, including openvswitch as far
as I can tell, should make use of the standard pmtud routing information that these update.

What I come back to, as before, is the simple notion that nothing forces an administrator to the otherwise unusual circumstance
of setting different MTUs on directly-attached common networks. If you want to bridge L2 traffic, make your MTU 1500 and it'll
work exactly as before. If you, instead, are using IPv4 or IPv6 and ordinary routed traffic, you can have 8X performance improvement
between hosts that can support it, even if other hosts on the same vswitch and outside your control cannot. You can talk to all
hosts on the vswitch, with a performance that matches the capabilities of each peer. I don't see any way that's not better.

									+-DLS
