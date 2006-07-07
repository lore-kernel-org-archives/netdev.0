From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC NET 00/04]: Increase number of possible routing tables
Date: Fri, 07 Jul 2006 11:13:54 -0700
Message-ID: <44AEA462.1080505@candelatech.com>
References: <20060703075259.6286.67397.sendpatchset@localhost.localdomain> <44AE15C3.8050900@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>, Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:63453 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S932248AbWGGSOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 14:14:16 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44AE15C3.8050900@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Patrick McHardy wrote:
> 
>>I took on Ben's challenge to increase the number of possible routing tables,
>>these are the resulting patches.

I am seeing problems..though they could be with the way I'm using the tool
or pehaps I patched the kernel incorrectly.

I applied the 3 patches to 2.6.17..all patches applied without problem,
but with a few lines of fuzz.  I get the same behaviour with and
without the new 'ip' patches applied.

If I do an 'ip ru show', then I see lots of tables, though not all it seems.
(I have not tried beyond 205 yet).  But, if I do an 'ip route show table XX',
then I see nothing or incorrect values.

For my test, I am creating 200 virtual interfaces (mac-vlans in my case, but
802.1q should work equally well.)  I am giving them all IP addrs on the same
subnet, and a routing table for each source IP addr.

The commands I run to generate the routing tables are found in this file:
http://www.candelatech.com/oss/gc.txt

When I change back to kernel 2.6.16.16 with only my patchset applied, things
seem to be working, so it looks like an issue with the new kernel patches.
I can provide access to this machine as well as my full patch set, etc...

For whatever reason, table 5 does appear in a bizarre fashion:

[greear@grok lanforge]$ more ~/tmp/ip.txt
[root@sb65g2 lanforge]# ip route show table 5
10.1.2.0/24 via 10.1.2.2 dev eth1#0
default via 10.1.2.1 dev eth1#0
[root@sb65g2 lanforge]# ip route show table 4
[root@sb65g2 lanforge]# ip route show table 3
[root@sb65g2 lanforge]# ip route show table 2
[root@sb65g2 lanforge]# ip route show table 1
[root@sb65g2 lanforge]# ip route show table 0
10.1.2.0/24 via 10.1.2.2 dev eth1#0  table 5
default via 10.1.2.1 dev eth1#0  table 5

#  Here is a listing of 'ip ru show'.
[greear@grok lanforge]$ more ~/tmp/ru.txt
0:      from all lookup local
31203:  from 10.1.2.144 lookup 147
31204:  from 10.1.2.143 lookup 146
31205:  from 10.1.2.142 lookup 145
31206:  from 10.1.2.141 lookup 144
31207:  from 10.1.2.140 lookup 143
31208:  from 10.1.2.139 lookup 142
31209:  from 10.1.2.138 lookup 141
31210:  from 10.1.2.137 lookup 140
31211:  from 10.1.2.136 lookup 139
31212:  from 10.1.2.135 lookup 138
31213:  from 10.1.2.134 lookup 137
31214:  from 10.1.2.133 lookup 136
31215:  from 10.1.2.132 lookup 135
31216:  from 10.1.2.131 lookup 134
31217:  from 10.1.2.130 lookup 133
31218:  from 10.1.2.129 lookup 132
31219:  from 10.1.2.128 lookup 131
31220:  from 10.1.2.127 lookup 130
31221:  from 10.1.2.126 lookup 129
31222:  from 10.1.2.125 lookup 128
31223:  from 10.1.2.124 lookup 127
31224:  from 10.1.2.123 lookup 126
31225:  from 10.1.2.122 lookup 125
31226:  from 10.1.2.121 lookup 124
31227:  from 10.1.2.120 lookup 123
31228:  from 10.1.2.119 lookup 122
31229:  from 10.1.2.118 lookup 121
31230:  from 10.1.2.117 lookup 120
31231:  from 10.1.2.116 lookup 119
31232:  from 10.1.2.115 lookup 118
31233:  from 10.1.2.114 lookup 117
31234:  from 10.1.2.113 lookup 116
31235:  from 10.1.2.201 lookup 204
31236:  from 10.1.2.200 lookup 203
31237:  from 10.1.2.199 lookup 202
31238:  from 10.1.2.198 lookup 201
31239:  from 10.1.2.197 lookup 200
31240:  from 10.1.2.196 lookup 199
31241:  from 10.1.2.195 lookup 198
31242:  from 10.1.2.112 lookup 115
31243:  from 10.1.2.111 lookup 114
31244:  from 10.1.2.110 lookup 113
31245:  from 10.1.2.109 lookup 112
31246:  from 10.1.2.108 lookup 111
31247:  from 10.1.2.107 lookup 110
31248:  from 10.1.2.106 lookup 109
31249:  from 10.1.2.105 lookup 108
31250:  from 10.1.2.104 lookup 107
31251:  from 10.1.2.103 lookup 106
31252:  from 10.1.2.102 lookup 105
31253:  from 10.1.2.101 lookup 104
31254:  from 10.1.2.100 lookup 103
31255:  from 10.1.2.99 lookup 102
31256:  from 10.1.2.98 lookup 101
31257:  from 10.1.2.97 lookup 100
31258:  from 10.1.2.96 lookup 99
31259:  from 10.1.2.95 lookup 98
31260:  from 10.1.2.94 lookup 97
31261:  from 10.1.2.93 lookup 96
31262:  from 10.1.2.92 lookup 95
31263:  from 10.1.2.91 lookup 94
31264:  from 10.1.2.90 lookup 93
31265:  from 10.1.2.89 lookup 92
31266:  from 10.1.2.88 lookup 91
31267:  from 10.1.2.87 lookup 90
31268:  from 10.1.2.86 lookup 89
31269:  from 10.1.2.85 lookup 88
31270:  from 10.1.2.84 lookup 87
31271:  from 10.1.2.83 lookup 86
31272:  from 10.1.2.82 lookup 85
31273:  from 10.1.2.81 lookup 84
31274:  from 10.1.2.80 lookup 83
31275:  from 10.1.2.79 lookup 82

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

