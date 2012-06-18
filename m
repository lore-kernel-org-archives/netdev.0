From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: unstable 10GBE performance with recent kernels (> 3.0.X)
Date: Mon, 18 Jun 2012 12:05:09 +0200
Message-ID: <4FDEFD55.7010204@profihost.ag>
References: <4FDEF34C.808@profihost.ag> <1340012706.7491.770.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:54411 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752922Ab2FRKFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 06:05:12 -0400
In-Reply-To: <1340012706.7491.770.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 18.06.2012 11:45, schrieb Eric Dumazet:
> On Mon, 2012-06-18 at 11:22 +0200, Stefan Priebe - Profihost AG wrote:
>> Hello list,
>>
>> i've discovered very unstable 10GBE performance using recent kernels.
>> I'm using some optimized settings mentioned by intel here
>> (part:Improving Performance):
>> http://downloadmirror.intel.com/5874/eng/README.txt
>>
> like what settings ?

Sorry these ones:
http://pastebin.com/raw.php?i=J2XRFAjD

>> Any ideas?
>
> ethtool -S eth0
 From host1 and 2: http://pastebin.com/raw.php?i=0Pp8Vs3Y

> ethtool -k eth0
 From host1 and 2: # ethtool -k eth2
Offload parameters for eth2:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: on
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
ntuple-filters: off
receive-hashing: on

# ethtool -k eth2
Offload parameters for eth2:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: on
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
ntuple-filters: off
receive-hashing: on

> netstat -s   (on sender, on receiver)

 From host1 and 2: http://pastebin.com/raw.php?i=P9T96j0L

> single flow , multiple flows ?

host1: iperf -s
host2: iperf -c ssdstor002 -d -t 600 -i 10;

In this test i got around 7.4Gbit/s

Stefan
