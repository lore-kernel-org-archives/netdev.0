From: bert hubert <bert.hubert@netherlabs.nl>
Subject: 2.6.18-rc6 memory mapped pcap truncates outgoing TCP packets, but not icmp
Date: Wed, 13 Sep 2006 13:23:07 +0200
Message-ID: <20060913112307.GA1374@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpost.ds9a.nl ([213.244.168.210]:47288 "EHLO outpost.ds9a.nl")
	by vger.kernel.org with ESMTP id S1750699AbWIMLXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 07:23:33 -0400
To: cpw@lanl.gov, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi people,

I like to use memory mapped pcap (PACKET_MMAP) since off the shelf, linux is
a tad prone to drop packets while capturing these days. It used to be lots
better at it, but right now memory mapped pcap is the only way to get things
working a bit. I've noticed this on many machines.

However, memory mapped pcap has started to truncate outgoing packets for me
recently, and interestingly, I only see this with locally generated TCP
packets, not with locally generated ICMP packets. I haven't yet tried UDP,
nor actual sniffing, this is all locally generated packets going out on
eth0.

Incoming packets are not truncated.

My commandline:
# PCAP_VERBOSE=1 PCAP_FRAMES=15000 tcpdump  -i eth0 -s 1600 -p -w test-dump
libpcap version: 0.9
Kernel filter, Protocol 0300, MMAP mode (12188 frames, snapshot 1600), socket type: Raw
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 1600 bytes


Within this dump we find the following outgoing TCP packet:
Frame 289 (553 bytes on wire, 66 bytes captured)
    Arrival Time: Sep 13, 2006 13:18:31.960250000
    Time delta from previous packet: 0.000072000 seconds
    Time since reference or first frame: 42.738582000 seconds
    Frame Number: 289
    Packet Length: 553 bytes
    Capture Length: 66 bytes
    Protocols in frame: eth:ip:tcp
    Type: IP (0x0800)
Internet Protocol, Src: 10.0.3.146 (10.0.3.146), Dst: 82.165.25.125 (82.165.25.125)

Which is truncated!

However, we also find this incoming packet:
Frame 290 (1508 bytes on wire, 1508 bytes captured)
    Arrival Time: Sep 13, 2006 13:18:32.036536000
    Time delta from previous packet: 0.076286000 seconds
    Time since reference or first frame: 42.814868000 seconds
    Frame Number: 290
    Packet Length: 1508 bytes
    Capture Length: 1508 bytes
    Protocols in frame: eth:ip:tcp:http
Internet Protocol, Src: 82.165.25.125 (82.165.25.125), Dst: 10.0.3.146 (10.0.3.146)

Which looks just fine.

Downgrading to 'normal' mode fixes this problem, but suffers from too much
packet loss to be useful.

My tcpdump is built with:
http://public.lanl.gov/cpw/libpcap-0.9.20060417.tar.gz

It used to work just fine, but I haven't been able to find when it broke.

Please let me know how I can help solve this!

	Bert

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
