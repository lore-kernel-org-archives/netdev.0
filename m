From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH net] af_unix: Guard against other == sk in unix_dgram_sendmsg
Date: Fri, 12 Feb 2016 13:25:15 +0000
Message-ID: <8760xuvz5w.fsf@doppelsaurus.mobileactivedefense.com>
References: <56B4BF9D.9070609@pmhahn.de> <56BC90E7.7040007@pmhahn.de>
	<87fuwzkzr5.fsf@doppelsaurus.mobileactivedefense.com>
	<1455210224.2801.21.camel@decadent.org.uk>
	<87r3gjjgbu.fsf@doppelsaurus.mobileactivedefense.com>
	<87egcjcd5j.fsf@doppelsaurus.mobileactivedefense.com>
	<87r3gj11jc.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<56BDA3A8.6070807@pmhahn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sasha Levin <sasha.levin@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Karolin Seeger <kseeger@samba.org>,
	Jason Baron <jbaron@akamai.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arvid Requate <requate@univention.de>,
	Stefan Gohmann <gohmann@univention.de>, netdev@vger.kernel.org
To: Philipp Hahn <pmhahn@pmhahn.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:45092 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752309AbcBLNZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 08:25:45 -0500
In-Reply-To: <56BDA3A8.6070807@pmhahn.de> (Philipp Hahn's message of "Fri, 12
	Feb 2016 10:19:36 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Philipp Hahn <pmhahn@pmhahn.de> writes:

> Hello Rainer,
>
> Am 11.02.2016 um 20:37 schrieb Rainer Weikusat:
>> The unix_dgram_sendmsg routine use the following test
>> 
>> if (unlikely(unix_peer(other) != sk && unix_recvq_full(other))) {

[...]

>> This isn't correct as the> specified address could have been bound to
>> the sending socket itself

[...]

> After applying that patch at least my machine running the samba test no
> longer crashes.

There's a possible gotcha in there: Send-to-self used to be limited by
the queue limit. But the rationale for that (IIRC) was that someone
could keep using newly created sockets to queue ever more data to a
single, unrelated receiver. I don't think this should apply when
receiving and sending sockets are identical. But that's just my
opinion. The other option would be to avoid the unix_state_double_lock
for sk == other. I'd be willing to change this accordingly if someone
thinks the queue limit should apply to send-to-self.
