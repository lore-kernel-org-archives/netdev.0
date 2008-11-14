From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Linux 2.6.27.5 / SFQ/HTB scheduling problems
Date: Fri, 14 Nov 2008 07:21:14 +0000
Message-ID: <20081114072114.GA4408@ff.dom.local>
References: <20081113142958.36pzkmzwtxd3wbox@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sami Farin <safari-kernel@safari.iki.fi>
To: Linux Networking Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:42463 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbYKNHVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 02:21:21 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1566550ugf.37
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2008 23:21:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081113142958.36pzkmzwtxd3wbox@m.safari.iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-11-2008 15:29, Sami Farin wrote:
...
> Oh, I had old ethtool..
> These with v 6:
> 
> # ethtool -k eth0
> Offload parameters for eth0:
> rx-checksumming: off
> tx-checksumming: off
> scatter-gather: off
> tcp segmentation offload: off
> udp fragmentation offload: off
> generic segmentation offload: on
> 
> Wow.  I turned gso off and now it works just like before.
> No packets over size of mtu anymore, either.
> 
> State       Recv-Q Send-Q               Local Address:Port                 Peer Address:Port
> ESTAB      0      122334        80.223.84.180:57694        74.54.226.166:80     timer:(on,4.475ms,0) uid:518 ino:4546485 sk:2ea3ac80ffff8800
>          ts sackcubic wscale:8,3 rto:4499 rtt:2914.12/378.5 cwnd:134 ssthresh:30 send 522.4Kbps rcv_space:5728
> 
> --- 84.250.192.1 ping statistics ---
> 50 packets transmitted, 50 received, 0% packet loss, time 1877ms
> rtt min/avg/max/mdev = 22.463/38.354/99.126/13.738 ms, pipe 3, ipg/ewma 38.309/34.963 ms
> 
> ... 
>> Anyway these TSO/GSO/jumbo_frames are usually bad idea with packet
>> schedulers (or need more tweaking - e.g. sfq quantum).
> 
> Well this GSO on by default was an unexpected surprise for me, for sure.
> 
> Maybe a warning on htb (or something) module load
> "GSO enabled, everything might not work as expected, try 
> 'ethtool -K eth0 gso off' to turn GSO off"..? ;)

I agree, such a warning could be useful.

BTW, r2q == 1 in your config could harm latency too; if it's because
of quantum warnings, usually (if there are big rate differences
between classes) it's better to use htb class's "quantum" parameter
(tc class add htb help).

Jarek P.

PS: it seems your mailer setting prevents adding your email as "To:"
while doing "Reply All". Sometimes it's intended, but not the most
popular on this list (e.g. I'd prefer to be "To/Cc-ed", because I'm
not a subscriber at the moment).
