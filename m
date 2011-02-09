From: Anders Berggren <anders@halon.se>
Subject: Re: [E1000-devel] [PATCH] fixing hw timestamping in igb
Date: Wed, 9 Feb 2011 10:27:39 +0100
Message-ID: <A6CC06B1-6D91-41FE-8D6A-AF12A8A9BBF3@halon.se>
References: <9D02360A-8016-4BCB-B14A-DAFE22EF558E@halon.se> <1296775407.2698.10.camel@jtkirshe-MOBL1> <331E9D4A-6738-405A-8457-14858D1072DA@halon.se> <DDC57477F5D6F845A0DDCB99D3C4812D0D36DA5C59@orsmsx510.amr.corp.intel.com> <98900162-6C81-4B10-87DD-F43B04DC3F71@halon.se> <1297241801.17359.169.camel@Joe-Laptop>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vsp.halon.se ([212.37.18.222]:57593 "EHLO vsp.halon.se"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751512Ab1BIJ1p convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Feb 2011 04:27:45 -0500
In-Reply-To: <1297241801.17359.169.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Feb 9, 2011, at 9:56 AM, Joe Perches wrote:

> On Wed, 2011-02-09 at 09:24 +0100, Anders Berggren wrote:
>> Our hardware ping, using Intel 82580 NICs,
>> have an accuracy of 8 nanoseconds.
> 
> Perhaps you mean 8 nanosecond resolution?
> Is documentation available for this claim?

Well, both. 8 ns is the accuracy when performing RTT (round-trip time) measurements using our hardware ping tool. We tested it by connecting a 10 m (European meters ;) CAT6 copper and measuring the jitter. The RTT is always 1240 ns or 1248 ns, hence the accuracy of 8 ns.

$ sudo ./probed -c 10.10.10.3 -i eth2 -p 666
SLA-NG probed 0.1
probed: Binding port 666
probed: Using hardware timestamps
probed: client: ::ffff:10.10.10.3: Connecting to port 666
probed: client: ::ffff:10.10.10.3: Connected
Response    1 from 0 in 1240 ns
Response    2 from 0 in 1248 ns
Response    3 from 0 in 1248 ns
Response    4 from 0 in 1248 ns
^C
4 ok, 0 ts err, 0 lost pong, 0 timeout, 0 dup, 0.000000% loss
max: 1248 ns, avg: 1246 ns, min: 1240 ns

This is our tool: 

$ ./probed 
SLA-NG probed 0.1
usage: probed [-saqd] [-c addr] [-t type] [-i iface] [-p port] [-f file]

	          MODES OF OPERATION
	-c addr   Client mode: PING 'addr', fetch UDP timestamps
	-s        Server mode: respond to PING, send UDP timestamps
	-d        Daemon mode: both server and client, output to pipe

	          OPTIONS
	-k        Create timestamps in kernel driver instead of hardware
	-u        Create timestamps in userland instead of hardware
	-i iface  Network interface used for hardware timestamping
	-p port   UDP port, both source and destination
	-w usecs  Client mode wait time between PINGs, in microseconds
	-v        Output more debugging
	-q        Be quiet, log error to syslog only
	-f file   Path to configuration file

