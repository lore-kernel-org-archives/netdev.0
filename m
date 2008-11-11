From: Sami Farin <safari-kernel@safari.iki.fi>
Subject: Re: Linux 2.6.27.5 / SFQ/HTB scheduling problems
Date: Tue, 11 Nov 2008 23:47:02 +0200
Message-ID: <20081111214702.subn3mt7uylkiref@m.safari.iki.fi>
References: <20081111151722.2fxd73nd67slyqac@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux Networking Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-out.inet.fi ([195.156.147.13]:57095 "EHLO jenni2.inet.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750808AbYKKVrG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 16:47:06 -0500
Received: from safari.iki.fi (80.223.84.180) by jenni2.inet.fi (8.5.014)
        id 48FC5A880124F040 for netdev@vger.kernel.org; Tue, 11 Nov 2008 23:47:03 +0200
Content-Disposition: inline
In-Reply-To: <20081111151722.2fxd73nd67slyqac@m.safari.iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2008 at 17:17:22 +0200, Sami Farin wrote:
> (testmy.net speed test reports 28 KiB/s)

Calculating with tcpdump+tcptrace I get 48.7 KiB/s, that
site calculated speed from 2900 KiB when I uploaded 5282 KiB.

But that's irrelevant, I am more interested in finding
why I'm getting lagged to death.

Hmmh I am not getting 1s delays anymore, but still quite bad...

I noticed TSC sync is not working in 2.6.27.5, worked ok in 2.6.25.
I have Intel DQ965GF mobo.

[    0.000999] x86 PAT enabled: cpu 1, old 0x7040600070406, new 0x7010600070106
[    0.093769] CPU1:               Intel(R) Pentium(R) D CPU 2.80GHz stepping 07
[    0.094107] checking TSC synchronization [CPU#0 -> CPU#1]:
[    0.094999] Measured 3983 cycles TSC warp between CPUs, turning off TSC clock.
[    0.094999] Marking TSC unstable due to check_tsc_sync_source failed

486Kbit limit

--- 84.250.192.1 ping statistics ---
50 packets transmitted, 50 received, 0% packet loss, time 3517ms
rtt min/avg/max/mdev = 26.922/82.323/169.725/36.659 ms, pipe 5, ipg/ewma 71.791/80.044 ms

256Kbit limit

--- 84.250.192.1 ping statistics ---
50 packets transmitted, 50 received, 0% packet loss, time 3237ms
rtt min/avg/max/mdev = 22.174/53.266/190.722/37.690 ms, pipe 3, ipg/ewma 66.071/40.314 ms



Then I ruled out my ISP by rebooting to 2.6.25.19:

486Kbit limit

--- 84.250.192.1 ping statistics ---
50 packets transmitted, 50 received, 0% packet loss, time 1912ms
rtt min/avg/max/mdev = 22.270/38.025/64.843/10.604 ms, pipe 2, ipg/ewma 39.025/35.386 ms

State       Recv-Q Send-Q               Local Address:Port                 Peer Address:Port
ESTAB      0      150520        80.223.84.180:65184        74.54.226.166:80     timer:(on,1.564ms,0) uid:518 ino:17634 sk:7dd88d00ffff8100
         ts sackcubic wscale:8,3 rto:1621 rtt:895.125/65 cwnd:49 ssthresh:44 send 621.9Kbps rcv_space:5728



When 2.6.27.5 was sending:

2008-11-11T21:16:13.488287Z IP (tos 0x0, ttl 255, id 10323, offset 0, flags [none], proto TCP (6), length 7152) 80.223.84.180.40449 > 74.54.226.166.80: ., cksum 0xee52 (incorrect (-> 0x96a4), 4123538094:4123545194(7100) ack 1017886112 win 710 <nop,nop,timestamp 418352 372760162>
2008-11-11T21:16:13.620018Z IP (tos 0x0, ttl 255, id 10328, offset 0, flags [none], proto TCP (6), length 7152) 80.223.84.180.40449 > 74.54.226.166.80: ., cksum 0xee52 (incorrect (-> 0xf1d0), 4123545194:4123552294(7100) ack 1017886112 win 710 <nop,nop,timestamp 418458 372760270>
2008-11-11T21:16:13.751751Z IP (tos 0x0, ttl 255, id 10333, offset 0, flags [none], proto TCP (6), length 7152) 80.223.84.180.40449 > 74.54.226.166.80: ., cksum 0xee52 (incorrect (-> 0xc685), 4123552294:4123559394(7100) ack 1017886112 win 710 <nop,nop,timestamp 418562 372760374>

I noticed it's 7152 bytes a packet!
Is this a new trick in 2.6.27 or 2.6.26?
But:
<3>[ 1583.914947] 0000:00:19.0: eth0: Jumbo Frames not supported.

-- 
"Courage is grace under pressure." - Ernest Hemingway

