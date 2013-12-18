From: Hector Palacios <hector.palacios@digi.com>
Subject: Re: FEC performance degradation with certain packet sizes
Date: Wed, 18 Dec 2013 17:43:50 +0100
Message-ID: <52B1D0C6.6010305@digi.com>
References: <528F50AE.3030804@digi.com> <201311240540.23813.marex@denx.de> <529310A4.70906@digi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "fabio.estevam@freescale.com" <fabio.estevam@freescale.com>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	<l.stach@pengutronix.de>, Frank Li <Frank.Li@freescale.com>,
	<fugang.duan@freescale.com>, <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Marek Vasut <marex@denx.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.bemta12.messagelabs.com ([216.82.251.8]:29017 "EHLO
	mail1.bemta12.messagelabs.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750853Ab3LRQu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 11:50:59 -0500
In-Reply-To: <529310A4.70906@digi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm resending this thread (reworded the subject) with additional people on CC.
I found the issue happens also with auto-negotiated link and is reproducible on the 
i.MX6 as well as on the i.MX28. It looks like a problem with the fec driver.

Steps to reproduce:
On the target:
	netpipe
On the host:
	netpipe -h <target_ip> -n 5

At certain packet sizes (starting always at 1533 bytes), the performance drops 
dramatically:

On i.MX28:
[...]
  42:     771 bytes      5 times -->     19.78 Mbps in     297.41 usec
  43:    1021 bytes      5 times -->     23.29 Mbps in     334.41 usec
  44:    1024 bytes      5 times -->     23.61 Mbps in     330.90 usec
  45:    1027 bytes      5 times -->     23.43 Mbps in     334.41 usec
  46:    1533 bytes      5 times -->      0.13 Mbps in   88817.49 usec
  47:    1536 bytes      5 times -->      0.06 Mbps in  189914.91 usec
  48:    1539 bytes      5 times -->      0.06 Mbps in  204917.19 usec
  49:    2045 bytes      5 times -->      0.07 Mbps in  210931.79 usec
  50:    2048 bytes      5 times -->      0.07 Mbps in  210919.10 usec
  51:    2051 bytes      5 times -->      0.07 Mbps in  212915.71 usec
  52:    3069 bytes      5 times -->     35.42 Mbps in     661.01 usec
  53:    3072 bytes      5 times -->     35.57 Mbps in     659.00 usec
  54:    3075 bytes      5 times -->     35.42 Mbps in     662.29 usec
  55:    4093 bytes      5 times -->     40.03 Mbps in     780.19 usec
  56:    4096 bytes      5 times -->     40.75 Mbps in     766.79 usec
  57:    4099 bytes      5 times -->     40.64 Mbps in     769.49 usec
  58:    6141 bytes      5 times -->      3.08 Mbps in   15187.90 usec
  59:    6144 bytes      5 times -->      2.94 Mbps in   15928.19 usec
  60:    6147 bytes      5 times -->      5.57 Mbps in    8418.91 usec
  61:    8189 bytes      5 times -->      1.34 Mbps in   46574.90 usec
  62:    8192 bytes      5 times -->      2.17 Mbps in   28781.99 usec
  63:    8195 bytes      5 times -->      1.36 Mbps in   45923.69 usec
  64:   12285 bytes      5 times -->     51.78 Mbps in    1810.21 usec
  65:   12288 bytes      5 times -->     50.46 Mbps in    1857.81 usec
  66:   12291 bytes      5 times -->     54.01 Mbps in    1736.21 usec
  67:   16381 bytes      5 times -->     55.86 Mbps in    2237.50 usec
  68:   16384 bytes      5 times -->     56.93 Mbps in    2195.79 usec
  69:   16387 bytes      5 times -->     35.62 Mbps in    3509.60 usec
  70:   24573 bytes      5 times -->      7.19 Mbps in   26075.60 usec
  71:   24576 bytes      5 times -->     58.36 Mbps in    3212.59 usec
  72:   24579 bytes      5 times -->      7.92 Mbps in   23678.90 usec
  73:   32765 bytes      5 times -->     58.14 Mbps in    4299.79 usec
  74:   32768 bytes      5 times -->      5.34 Mbps in   46810.20 usec
  75:   32771 bytes      5 times -->     41.51 Mbps in    6023.21 usec
  76:   49149 bytes      5 times -->     49.62 Mbps in    7557.20 usec
  77:   49152 bytes      5 times -->     48.82 Mbps in    7681.11 usec

On i.MX6:
[...]
  42:     771 bytes      5 times -->     16.21 Mbps in     362.91 usec
  43:    1021 bytes      5 times -->     17.97 Mbps in     433.51 usec
  44:    1024 bytes      5 times -->     18.19 Mbps in     429.40 usec
  45:    1027 bytes      5 times -->     18.16 Mbps in     431.41 usec
  46:    1533 bytes      5 times -->      2.35 Mbps in    4970.11 usec
  47:    1536 bytes      5 times -->      2.36 Mbps in    4959.91 usec
  48:    1539 bytes      5 times -->      2.37 Mbps in    4959.20 usec
  49:    2045 bytes      5 times -->      3.14 Mbps in    4972.31 usec
  50:    2048 bytes      5 times -->      3.15 Mbps in    4959.50 usec
  51:    2051 bytes      5 times -->      3.15 Mbps in    4960.01 usec
  52:    3069 bytes      5 times -->      4.70 Mbps in    4984.19 usec
  53:    3072 bytes      5 times -->      4.73 Mbps in    4960.10 usec
  54:    3075 bytes      5 times -->      4.73 Mbps in    4957.81 usec
  55:    4093 bytes      5 times -->      6.29 Mbps in    4966.71 usec
  56:    4096 bytes      5 times -->      6.30 Mbps in    4962.00 usec
  57:    4099 bytes      5 times -->      6.31 Mbps in    4957.71 usec
  58:    6141 bytes      5 times -->     49.25 Mbps in     951.40 usec
  59:    6144 bytes      5 times -->     49.23 Mbps in     952.21 usec
  60:    6147 bytes      5 times -->     49.18 Mbps in     953.69 usec

Does anyone have any clue about where the problem might be?

Best regards,
--
Hector Palacios


On 11/25/2013 09:56 AM, Hector Palacios wrote:
> On 11/24/2013 05:40 AM, Marek Vasut wrote:
>> Hi Hector,
>>
>>> Hello,
>>>
>>> When forcing the Ethernet PHY link media with ethtool/mii-tool on the
>>> i.MX28 I've seen important performance degradation as the packet size
>>> increases.
>>>
>>> On the target:
>>> # mii-tool eth0 -F 10baseT-FD
>>> # netpipe
>>>
>>> On the host:
>>> # netpipe -h <target-ip> -n 1
>>> ...
>>> 44:    1024 bytes      1 times -->      6.56 Mbps in    1191.00 usec
>>> 45:    1027 bytes      1 times -->      6.56 Mbps in    1193.52 usec
>>> 46:    1533 bytes      1 times -->      0.60 Mbps in   19600.54 usec
>>> 47:    1536 bytes      1 times -->      0.46 Mbps in   25262.52 usec
>>> 48:    1539 bytes      1 times -->      0.57 Mbps in   20745.54 usec
>>> 49:    2045 bytes      1 times -->      0.74 Mbps in   20971.95 usec
>>> ...
>>> On loop 46, as the packet size exceeds the MTU (1500) performance falls
>>> from 6.56Mbps to 0.60Mbps.
>>>
>>> Going back to 100baseTX-FD, but still forced (autonegotiation off), the
>>> same occurs: On the target:
>>> # mii-tool eth0 -F 100baseTx-FD
>>> # netpipe
>>>
>>> On the host:
>>> # netpipe -h <target-ip> -n 1
>>> ...
>>> 58:    6141 bytes      1 times -->     39.74 Mbps in    1179.03 usec
>>> 59:    6144 bytes      1 times -->     41.83 Mbps in    1120.51 usec
>>> 60:    6147 bytes      1 times -->     41.39 Mbps in    1133.03 usec
>>> 61:    8189 bytes      1 times -->      6.36 Mbps in    9823.94 usec
>>> 62:    8192 bytes      1 times -->      6.56 Mbps in    9521.46 usec
>>> 63:    8195 bytes      1 times -->      6.56 Mbps in    9532.99 usec
>>> ...
>>> only this time it happens with a larger packet size (8189 bytes).
>>>
>>> With autonegotiation on, performance is ok and does not suffer these drops.
>>>
>>> I've reproduced this on the mx28evk board but it also happens in my
>>> hardware, with different PHY on v3.10.
>>> I also tried on an old v2.6.35 kernel and the issue was reproducible as
>>> well, though it happened with larger packet sizes than it happens with
>>> v3.10:
>>> ...
>>> 75:   32771 bytes      1 times -->     49.64 Mbps in    5036.50 usec
>>> 76:   49149 bytes      1 times -->     46.18 Mbps in    8120.48 usec
>>> 77:   49152 bytes      1 times -->     43.30 Mbps in    8660.46 usec
>>> 78:   49155 bytes      1 times -->     40.10 Mbps in    9351.46 usec
>>> 79:   65533 bytes      1 times -->      2.03 Mbps in  246061.04 usec
>>> 80:   65536 bytes      1 times -->      2.21 Mbps in  226516.50 usec
>>> 81:   65539 bytes      1 times -->      1.45 Mbps in  344196.46 usec
>>> ...
>>>
>>> Could there be any issue with packet fragmentation?
>>> I tried the same on imx6sabresd but here the issue is not reproducible. I
>>> don't know if the higher CPU frequency might be hiding the problem,
>>> though.
>>>
>>> Any idea about what can make the difference between forcing media vs
>>> autonegotiation?
>>
>> Let me ask, this might be unrelated, but I will still go ahead. Do you also
>> observe packetloss? You can check with iperf:
>>
>> On host machine (PC): iperf -u -s -l 4M -i 60
>> On target: iperf -u -c <hostip> -t 3600 -B 100M -i 60
>
> Yes, with forced 100baseTX-FD there is a small packet loss:
>
> [ ID] Interval       Transfer     Bandwidth        Jitter   Lost/Total Datagrams
> [  3]  0.0-60.0 sec   339 MBytes  47.4 Mbits/sec   0.075 ms   61/242070 (0.025%)
> [  3] 60.0-120.0 sec   339 MBytes  47.4 Mbits/sec   0.209 ms   45/242122 (0.019%)
> [  3] 120.0-180.0 sec   339 MBytes  47.5 Mbits/sec   0.084 ms   70/242237 (0.029%)
> [  3] 180.0-240.0 sec   339 MBytes  47.4 Mbits/sec   0.030 ms   80/241993 (0.033%)
> [  3] 240.0-300.0 sec   340 MBytes  47.5 Mbits/sec   0.042 ms  111/242363 (0.046%)
> [  3] 300.0-360.0 sec   339 MBytes  47.4 Mbits/sec   0.038 ms   93/241972 (0.038%)
> [  3] 360.0-420.0 sec   339 MBytes  47.5 Mbits/sec   0.030 ms   78/242214 (0.032%)
> [  3] 420.0-480.0 sec   339 MBytes  47.4 Mbits/sec   0.090 ms   77/241980 (0.032%)
> [  3] 480.0-540.0 sec   339 MBytes  47.4 Mbits/sec   0.025 ms  125/242058 (0.052%)
>
> With autonegotiated 100baseTX-FD, there is not:
>
> [ ID] Interval       Transfer     Bandwidth        Jitter   Lost/Total Datagrams
> [  3]  0.0-60.0 sec   336 MBytes  47.0 Mbits/sec   0.038 ms    0/239673 (0%)
> [  3] 60.0-120.0 sec   337 MBytes  47.1 Mbits/sec   0.078 ms    0/240353 (0%)
> [  3] 120.0-180.0 sec   337 MBytes  47.1 Mbits/sec   0.047 ms    0/240054 (0%)
> [  3] 180.0-240.0 sec   337 MBytes  47.1 Mbits/sec   0.038 ms    0/240195 (0%)
> [  3] 240.0-300.0 sec   337 MBytes  47.1 Mbits/sec   0.038 ms    0/240109 (0%)
> [  3] 300.0-360.0 sec   337 MBytes  47.1 Mbits/sec   0.035 ms    0/240101 (0%)
> [  3] 360.0-420.0 sec   337 MBytes  47.0 Mbits/sec   0.031 ms    0/240032 (0%)
> [  3] 420.0-480.0 sec   336 MBytes  47.0 Mbits/sec   0.036 ms    0/239912 (0%)
>
>
> Best regards,
> --
> Hector Palacios
