From: Peter Bieringer <pb@bieringer.de>
Subject: Re: netfilter6: ICMPv6 type 143 doesn't match (130 also not)
Date: Sun, 02 Jan 2005 10:12:42 +0100
Message-ID: <44BA844FEB4A052700F3C77E@worker.muc.bieringer.de>
References: <6050E336B1A0D7D8E70C66F3@t1mobil.muc.aerasec.de>
 	<200412270417.iBR4HZRG021429@toshiba.co.jp>
 <20041227.100205.102356251.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi-users@linux-ipv6.org, laforge@gnumonks.org,
        kaber@trash.net, netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=" <yoshfuji@linux-ipv6.org>,
        yasuyuki.kozakai@toshiba.co.jp
In-Reply-To: <20041227.100205.102356251.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

--On Monday, December 27, 2004 10:02:05 AM +0100 "YOSHIFUJI Hideaki /
=?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=" <yoshfuji@linux-ipv6.org> wrote:

> In article <200412270417.iBR4HZRG021429@toshiba.co.jp> (at Mon, 27 Dec
> 2004 13:17:34 +0900 (JST)), Yasuyuki Kozakai
> <yasuyuki.kozakai@toshiba.co.jp> says:
> 
>>  
>> -		ptr = IPV6_HDR_LEN;
>> +		ptr = ((u8*)skb->nh.ipv6h - skb->data) + IPV6_HDR_LEN;
>>  
> 
> IMHO, skb->nh.ipv6h does not points ipv6 header anymore;
> it should be skb->nh.raw in this case.
> 
> --yoshfuji

Can someone pls. provide me a patch for kernel version 2.6.9? If so, I
would run tests.

BTW: at the moment, I have an additional packet where no ICMPv6 rule
matches: 

Jan  2 10:04:15 gate kernel: default-drop-extIN:IN=sit1 OUT=
MAC=53:2e:55:**:**:**->00:00:65:**:**:** TUNNEL=212.224.
0.188->217.228.***.*** SRC=fe80:0000:0000:0000:0000:0000:d4e0:00bc
DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=76 TC=0 HOPLIMIT=1
FLOWLBL=0 OPT ( ) PROTO=ICMPv6 TYPE=130 CODE=0


10:08:25.540037 fe80::d4e0:bc > ff02::1: HBH icmp6: multicast listener
query max resp delay: 2000 addr: :: [hlim 1]
        0x0000:  6000 0000 0024 0001 fe80 0000 0000 0000  `....$..........
        0x0010:  0000 0000 d4e0 00bc ff02 0000 0000 0000  ................
        0x0020:  0000 0000 0000 0001 3a00 0502 0000 0100  ........:.......
        0x0030:  8200 a03a 07d0 0000 0000 0000 0000 0000  ...:............
        0x0040:  0000 0000 0000 0000 027d 0000            .........}..


# ip6tables -vnL INPUT --line-num
Chain INPUT (policy DROP 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source
destination
1        0     0 ACCEPT     icmpv6    *      *       ::/0
fe80::/10          ipv6-icmp type 136 HL match HL == 255
2        0     0 ACCEPT     icmpv6    *      *       ::/0
ff02::1:ff00:1/128 ipv6-icmp type 135 HL match HL == 255
3        0     0 ACCEPT     icmpv6    *      *       ::/128
fe80::/10          ipv6-icmp type 135 HL match HL == 255
4        0     0 ACCEPT     icmpv6    *      *       fe80::/10
::/0               ipv6-icmp type 135 HL match HL == 255
5        4   384 ACCEPT     icmpv6    *      *       fe80::/10
ff02::1/128        ipv6-icmp type 134 HL match HL == 255
6        0     0 ACCEPT     icmpv6    *      *       fe80::/10
fe80::/10          ipv6-icmp type 133 HL match HL == 255
7        0     0 ACCEPT     icmpv6    *      *       fe80::/10
ff02::1/128        ipv6-icmp type 130 HL match HL == 1
8        0     0 ACCEPT     icmpv6    *      *       ::/0
::/0               ipv6-icmp type 4
9        0     0 ACCEPT     icmpv6    *      *       ::/0
::/0               ipv6-icmp type 3
10       0     0 ACCEPT     icmpv6    *      *       ::/0
::/0               ipv6-icmp type 2
11       0     0 ACCEPT     icmpv6    *      *       ::/0
::/0               ipv6-icmp type 1


Expected: match of rule 7


        Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de 
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
