From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next,v2] gtp: add initial driver for datapath of GPRS
 Tunneling Protocol (GTP-U)
Date: Tue, 10 May 2016 19:31:28 +0200
Message-ID: <20160510173128.GA32285@salvia>
References: <1462748148-17764-1-git-send-email-pablo@netfilter.org>
 <20160510.122735.2275935466949423395.davem@davemloft.net>
 <CALx6S34cHSNmC-QLO8QrbktTwvJMpjkOnsQLEq3W4FLBannBRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	laforge@gnumonks.org, aschultz@tpip.net, openbsc@lists.osmocom.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48505 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751033AbcEJRbf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 13:31:35 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id BE7C64BCD7
	for <netdev@vger.kernel.org>; Tue, 10 May 2016 19:31:31 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id AB1BE2687D5
	for <netdev@vger.kernel.org>; Tue, 10 May 2016 19:31:31 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 8DA932687D3
	for <netdev@vger.kernel.org>; Tue, 10 May 2016 19:31:29 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <CALx6S34cHSNmC-QLO8QrbktTwvJMpjkOnsQLEq3W4FLBannBRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 10, 2016 at 10:16:33AM -0700, Tom Herbert wrote:
> On Tue, May 10, 2016 at 9:27 AM, David Miller <davem@davemloft.net> wrote:
> > From: Pablo Neira Ayuso <pablo@netfilter.org>
> > Date: Mon,  9 May 2016 00:55:48 +0200
> >
> >> This is an initial implementation of a netdev driver for GTP datapath
> >> (GTP-U) v0 and v1, according to the GSM TS 09.60 and 3GPP TS 29.060
> >> standards. This tunneling protocol is used to prevent subscribers from
> >> accessing mobile carrier core network infrastructure.
> >>
> >> This implementation requires a GGSN userspace daemon that implements the
> >> signaling protocol (GTP-C), such as OpenGGSN [1]. This userspace daemon
> >> updates the PDP context database that represents active subscriber
> >> sessions through a genetlink interface.
> >>
> >> For more context on this tunneling protocol, you can check the slides
> >> that were presented during the NetDev 1.1 [2].
> >>
> >> Only IPv4 is supported at this time.
> >>
> 
> Is there a timeline for adding IPv6 support?

There is a preliminary kernel patch to add IPv6 that seems to be
untested yet, I can share it with you or anyone else want to have a
look. Specifically, there are missing bits on the netlink side of the
PDP context database to support SGSN and MS IPv6 address, but that
shouldn't be much of a problem.

On the userspace side, the userspace daemon OpenGGSN still doesn't
support IPv6. Adding IPv6 support to this daemon is a bit of a PITA,
several people using it in production told me that the daemon runs
stable for production, but from a developer perspective the current
codebase look not easy to extend (quite many stuff very IPv4 specific,
I already spend time trying to refactor it two years ago to prepare
this support). Meanwhile, this triggered a new daemon daemon
implementation osmo-ggsn to replace it, I posted a proof-of-concept on
the openbsc mailing list, but nobody jumped on this to support this
development effort so far.
