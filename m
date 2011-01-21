From: Patrick Schaaf <netdev@bof.de>
Subject: RFC: pid "ownership" of ip config information
Date: Fri, 21 Jan 2011 10:28:11 +0100
Message-ID: <1295602091.3582.1.camel@lat1>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bof-2.saar.de ([192.109.53.146]:48924 "EHLO oknodo.bof.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752012Ab1AUJoX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jan 2011 04:44:23 -0500
Received: from pluto.locanto.info ([213.172.110.11] helo=[192.168.2.61])
	by oknodo.bof.de with esmtp (Exim 4.69)
	(envelope-from <netdev@bof.de>)
	id 1PgDHw-0001xC-OZ
	for netdev@vger.kernel.org; Fri, 21 Jan 2011 10:28:16 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear netdev,

I want to solicit comments on a feature enhancement that occured
to me recently.

Feature:

- For "ip addr add", "ip route add", "ip rule add", and maybe "ip link
add",
  implement an option 'pid XXXXX' to specify a PID
- if that PID is not currently existing, fail the operation
- if, at a later time, that PID dies, automatically remove the
configuration,
  as if a corresponding "ip ... del" would have been given

The feature would be useful in any kind of "IP takeover" scenario.

I'm concretely working on deployment of keepalived (VRRP address
takeover) and memcachedb (address takeover after berkeley DB master
selection).

It would also apply to all kinds of routing daemons (zebra, quagga...).

In all these cases, for as long as the process is working normally,
it can trigger the relevant address withdrawal, but when the process
dies unexpectedly (oom killer or whatever), addresses are left
configured,
while a partner on another host might take them over, resulting in
actively duplicate IPs and the application breaking.

The alternative to such a feature, would be to have an additional
monitoring process, which would watch the PID somehow, and need to
be configured to know what to withdraw when it dies.

Before I go ahead and try to implement that, I would like to have
some feedback regarding the idea 

- has it been discussed before?
- would it be accepted by the relevant maintainers? 
- did I overlook alternative solutions to the problem?

best regards
  Patrick


