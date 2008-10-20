From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [Bugme-new] [Bug 11752] New: Extremely low	netperf	UDP_RR	throughput
 for nvidia MCP65
Date: Mon, 20 Oct 2008 10:41:21 -0700
Message-ID: <48FCC2C1.5030108@hp.com>
References: <bug-11752-10286@http.bugzilla.kernel.org/>	<20081016134920.1492cdcc.akpm@linux-foundation.org>	<48F7AD1A.7050309@hp.com> <wp63nrx7zk.fsf@heho.snv.jussieu.fr>	<48F8FE18.6060005@hp.com> <wpprlyuoci.fsf@heho.snv.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>
To: "Arno J. Klaassen" <arno@heho.snv.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:13938 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246AbYJTRl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 13:41:26 -0400
In-Reply-To: <wpprlyuoci.fsf@heho.snv.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>Clearly something is fubar with the rx side (well duh :).  The next
>>set of stats I'd try to look at would be ethtool stats for the
>>interface, eg ethtool -S eth0 and see if it shows someting more
>>specific for the "RX-ERR" shown by netstat -I eth0.
> 
> 
> OK, here it is (rx_errors_total: 10049, rx_crc_errors: 10049) :

Well, that seems to confirm that it is CRC errors.  Did your friend say 
why he thought they were false CRC errors?

If indeed it is only small packets/frames getting the CRC errors, in 
_theory_ a TCP_RR test with a larger request/response size should show 
"good" performance because there should be few if any standalone ACKs. 
You could start with something like:

netperf -H <remote> -t TCP_RR -- -r 1448

and work your way down, checking for those CRC errors as you go.  I 
don't thnik folks need all the output, just some idea of if you still 
see CRC errors with full-size TCP_RR and if you don't at what size you 
start to see them.  I picked 1448 to have the request and response both 
result in a "full" TCP segment assuming an MTU of 1500 bytes and 
timestamps being enabled. (net.ipv4.tcp_timestamps).

Has the usual litany of cable swapping and such been done already?  A 
cable *known* to be good at 1G swapped-in and such?  If this is via a 
switch, just for completeness trying other switch ports etc etc.

While I'd not expect it to be at 1Gig and autoneg, CRC errors can 
sometimes be a sign of a duplex mismatch, but I have a difficult time 
seeing that happening - unless there happens to be other traffic on the 
link a plain netperf TCP_RR or UDP_RR test should "never" have both 
sides trying to talk at the same time and so shouldn't trip-over a 
duplex mismatch like a TCP_STREAM test would.

> (NB, let me know how to eventually test eventual patches/binary
> modules on a life-CD; I've just limited linux kernel skills)

I'm going to have to defer to others on that score.  Meanwhile some 
additional information gathering:

For grins and bugzilla posterity, ethtool -i <interface> would be 
goodness. What was the last "known good" configuration?  What is running 
"on the other side?" etc etc.  Does say some other or earlier distro 
(Fedora, Ubuntu whatnot) Live CD not exhibit this problem?  If not, what 
are the kernel and ethtool -i information from that?

rick jones
