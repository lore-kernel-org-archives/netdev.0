From: "Julius Volz" <juliusv@google.com>
Subject: Adding SNAT support to LVS/NAT
Date: Sat, 13 Sep 2008 13:12:54 +0200
Message-ID: <f4845fc0809130412n41967d79l1240558492c84cb7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: j.stubbs@linkthink.co.jp
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:49678 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753047AbYIMLM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2008 07:12:59 -0400
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id m8DBCt1A023589
	for <netdev@vger.kernel.org>; Sat, 13 Sep 2008 12:12:55 +0100
Received: from ey-out-2122.google.com (eyi6.prod.google.com [10.208.9.6])
	by spaceape9.eur.corp.google.com with ESMTP id m8DBCsvV008653
	for <netdev@vger.kernel.org>; Sat, 13 Sep 2008 04:12:54 -0700
Received: by ey-out-2122.google.com with SMTP id 6so521215eyi.61
        for <netdev@vger.kernel.org>; Sat, 13 Sep 2008 04:12:54 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm wondering about how hard it would be to add SNAT support to IPVS
(that is, the director rewriting packets from the client to backends
to appear to be from the VIP and some randomly allocated port). This
would allow us to have remote real servers with LVS/NAT. I realize
that Jason Stubb's PRE/POSTROUTING patches would also make this
possible, but they seemed risky and we haven't heard of them in a long
time. Also, having this option directly integrated into the rest of
the IPVS NAT code might make it easier to use: just add another flag
on the ipvsadm command line when you want SNAT for an LVS/NAT backend.

Two problems I noticed immediately:

- Getting a free port:
We need to find an unused port for the SNAT for each connection. Is
there some subsystem function than can be used to easily find/allocate
a free TCP/UDP port (sockets and netfilter NAT would need this too)?
Also, this would only allow <64k connections to each backend. The only
way to possibly differentiate between more would be to look at
sequence numbers, but IPVS doesn't do that at all currently...

- Connection entry lookup:
Connection entries are currently hashed and looked up by [client IP,
client port]. In the new SNAT case, packets coming from the real
server to the director would have to be looked up by [VIP, xport],
where xport is a port that is allocated by IPVS for each connection. A
simple (hacky?) solution would be to just hash each connection entry
twice. Is there a better way?

Are there any other major problems with this? Is it the right way to
go in general? I'm mainly just doing some exploration into this now...

Thanks for any comments!

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
