From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: [PATCH net] net: fq_codel: Fix off-by-one error
Date: Sat, 30 Mar 2013 07:53:45 +0100
Message-ID: <20130330065345.GA23938@x4>
References: <1364514720-20780-1-git-send-email-subramanian.vijay@gmail.com>
 <1364569280.5113.21.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ud10.udmedia.de ([194.117.254.50]:57510 "EHLO
	mail.ud10.udmedia.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790Ab3C3HA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Mar 2013 03:00:28 -0400
Content-Disposition: inline
In-Reply-To: <1364569280.5113.21.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013.03.29 at 08:01 -0700, Eric Dumazet wrote:
> 
> Just curious, did you play changing the default limit (10240 packets) ?

I did some tests on my home router (running OpenWrt trunk) that is rate-
limited with hfsc to the speed of the cable modem.

My tests seem to indicate that lowering the default limit to 1024
packets results in much better latency behavior when using bittorrent.

With the default limit (10240 packets) I would get huge ping latencies
from 600-1200ms when downloading e.g.:
http://download.opensuse.org/distribution/12.3/iso/openSUSE-12.3-DVD-x86_64.iso.torrent
with hundreds of peers.

Setting the limit to 1024 did get the latencies back in check (20-30ms
with occasional spikes of ~100ms).

fq_codel limit 1024:
 Host                                    Loss%   Snt   Last   Avg  Best  Wrst StDev
 1. OpenWrt.lan                           0.0%   179    0.2   0.3   0.2   1.0   0.1
 2. ???
 3. 83-169-179-150-isp.superkabel.de      0.6%   179   13.4  29.3   7.1 214.1  26.1
 4. 88-134-192-0-dynip.superkabel.de      0.6%   179   13.5  28.2   7.8 213.9  26.3
 5. 88-134-196-230-dynip.superkabel.de    1.1%   179   10.7  27.7   7.5 225.6  26.7
 6. 88-134-203-141-dynip.superkabel.de    0.6%   179   18.8  30.4   7.6 216.7  25.2
    88-134-203-10-dynip.superkabel.de
    88-134-203-6-dynip.superkabel.de
    88-134-203-14-dynip.superkabel.de
 7. 88-134-201-5-dynip.superkabel.de      0.6%   179    8.4  37.1   7.5 453.5  50.6
 8. ???
 9. 209.85.249.182                        0.6%   179   11.8  28.5   8.2 185.6  25.4
10. 66.249.95.175                         0.6%   179    9.2  34.5   8.3 263.9  31.3
    66.249.95.67
11. 64.233.174.29                         0.6%   179   13.4  30.6   7.8 297.8  31.7
    216.239.48.53
    64.233.174.55
12. ???
13. google-public-dns-a.google.com        0.0%   178   13.7  29.7   7.6 312.7  33.8

fq_codel limit 10240:
 Host                                    Loss%   Snt   Last   Avg  Best  Wrst StDev
 1. OpenWrt.lan                           0.0%   179    0.5   0.3   0.2   0.8   0.1
 2. ???
 3. 83-169-179-150-isp.superkabel.de      1.1%   179   13.4  98.9   7.6 888.4 170.0
 4. 88-134-192-0-dynip.superkabel.de      1.1%   179   16.8  95.5   8.0 892.5 171.9
 5. 88-134-196-230-dynip.superkabel.d     1.1%   179   12.8  96.2   7.7 913.8 173.8
 6. 88-134-203-6-dynip.superkabel.de      2.2%   179   38.2 105.9   9.5 926.1 175.9
    88-134-203-10-dynip.superkabel.de
    88-134-203-14-dynip.superkabel.de
    88-134-203-141-dynip.superkabel.de
 7. 88-134-201-5-dynip.superkabel.de      1.7%   179   44.0 103.3   8.0 960.6 178.9
 8. ???
 9. 209.85.249.182                        1.7%   179   20.8  98.7   7.7 900.0 176.1
10. 66.249.95.175                         1.7%   179   17.0 100.2   8.1 861.9 174.9
    66.249.95.67
11. 64.233.174.55                         1.7%   179   50.3 102.6   7.7 826.6 171.7
    216.239.48.53
    64.233.174.29
12. ???
13. google-public-dns-a.google.com        1.1%   179   12.5  98.2   8.1 849.8 168.9

-- 
Markus
