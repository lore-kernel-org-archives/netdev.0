From: Peter Bieringer <pb@bieringer.de>
Subject: ip6tables: accept of IPv6 transport esp packages not possible - no
 rule matches
Date: Fri, 24 Dec 2004 10:45:25 +0100
Message-ID: <019064D0423CE6C823CBF476@t1mobil.muc.aerasec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: USAGI core <usagi-core@linux-ipv6.org>,
        Maillist netdev <netdev@oss.sgi.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,

(first a Merry Christmas to all)

I ran here into a major problem:

2 IPv6 hosts can successfully connect each other in case of unencrypted 
traffic, filtering with ip6table works fine.

Now I'v setup between this two hosts encryption (setkey & racoon). IKE 
phase 1 & 2 works perfectly.

But now, no ip6table-ACCEPT rule matches anymore. I played around, but 
without success.

I got following log message (some MAC,IPv4,IPv6 addresses are changed for 
privacy):

Dec 24 10:22:27 gate kernel: extIN-FW6-default:IN=sit_sixxs OUT= 
MAC=00:11:22:33:44:01->00:11:22:33:44:02 TUNNEL=212.224.  0.188-> 84.000. 
0. 12 SRC=2001:06f8:0900:0449:0000:0000:0000:0002 
DST=2001:06f8:0900:0094:0000:0000:0000:0002 LEN=116 TC=0 HOPLIMIT=63 
FLOWLBL=0 OPT ( ) PROTO=59

Caused by following ruleset:

# ip6tables -vn -L extIN --line-num
Chain extIN (4 references)
num   pkts bytes target     prot opt in     out     source 
destination
1        0     0 ACCEPT     all      *      *       2001:6f8:900:449::2/128 
2001:6f8:900:94::2/128
2        0     0 ACCEPT     tcp      *      *       ::/0 
3ffe:400:100:f101::1/128tcp spts:1024:65535 dpt:80
3       27  2808 ACCEPT     icmpv6    *      *       ::/0 
::/0
4        6   888 ACCEPT     udp      *      *       2001:6f8:900:449::2/128 
2001:6f8:900:94::2/128udp spt:500 dpt:500
5        0     0 ACCEPT     esp      *      *       2001:6f8:900:449::2/128 
2001:6f8:900:94::2/128
6        0     0 ACCEPT     59       *      *       2001:6f8:900:449::2/128 
2001:6f8:900:94::2/128
tcp spts:512:65535 dpt:22
10       0     0 ACCEPT     tcp      *      *       ::/0 
::/0               tcp spts:1:65535 dpts:32768:60099 flags:!0x16/0x02
11       0     0 ACCEPT     udp      *      *       ::/0 
::/0               udp spts:1:65535 dpts:32768:60099
12      13  1564 LOG        all      *      *       ::/0 
::/0               limit: avg 5/min burst 5 LOG flags 0 level 7 prefix 
`extIN-FW6-default:'
13      13  1564 DROP       all      *      *       ::/0 
::/0


As you see, neither rule 1 nor rule 6 matches, which is strange indeed - 
what's the reason?

Why matches the DROP rule (13), but not the global ACCEPT rule (1)?

Both sides are using Linux kernel 2.6.9-1.681_FC3 from Fedora Core 3 
updates.


BTW: can someone fix the log statement?
	TUNNEL=212.224.  0.188-> 84.128.  0. 12
-> leading spaces instead of leading 0 are not very well.

Thank you very much.

	Peter
-- 
Dr. Peter Bieringer                        http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D                  mailto: pb at bieringer dot de
Deep Space 6 Co-Founder and Core Member     http://www.deepspace6.net/
