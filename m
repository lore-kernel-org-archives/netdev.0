From: "Xiaoliang (David) Wei" <weixl@caltech.edu>
Subject: Re: Handling a few hundred thousand TCP flows
Date: Sun, 1 Feb 2004 22:01:37 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <005401c3e952$04c279f0$f5f2010a@weixl>
References: <20040201215836.GC16978@gozdal.eu.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>, "Marcin Gozdalik" <gozdal@gozdal.eu.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
> I've been successfully using Linux 2.4 for handling many thousands TCP
> flows (300k non-stop). I've been wondering which options I should use to
> minimize CPU and memory consumption.
> I've followed the thread from December about handling 90k TCP streams
> and suggestions contained there. I thought however of some more radical
> solutions: disabling rt_cache altogether. The routing table contains
> whole 2 entries (for eth0 subnet and default gateway) so I'd assume that
> walking linearily such short list would be a win cache-wise compared to
> huge rt_cache? Or is it a completely stupid idea not worth implementing?
> Additionally, I've disabled ECN and SACKs. Does it make any sense? Or
> are performance/memory gains negligible?
    I think SACK will have some overhead since it goes through the
retransmission queue for each SACK option. But this only happens when the
ack packet contains SACK.
    For memory, Linux allocate a block of memory for each connection
(usually 64KB). This is the buffer for the sliding-window algorithm. You can
change this memory buffer size to be w. The principle is that: w*N cannot be
too large in comparison to the memory in you machine (where N is # of
connections). The effect of a small buffer size w is that the window for
each TCP conneciton cannot be high -- hence the throughput of each flow is
low if the RTT is not negligible.
    Web100 project (http://www.web100.org) provide a patch to dynamically
allocate memory for different flows and maintains a static size of aggregate
buffer for all the connections.


-David
