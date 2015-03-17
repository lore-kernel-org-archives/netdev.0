From: =?UTF-8?B?0KHQvtC70L7QstGM0LXQsiDQodC10YDQs9C10Lk=?= <sol@eqv.ru>
Subject: Possible bug in tc tool or kernel
Date: Tue, 17 Mar 2015 12:57:28 +0300
Message-ID: <5507FA88.60303@eqv.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.deltelecom.ru ([195.54.177.82]:35931 "EHLO
	ns2.deltelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932213AbbCQKay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 06:30:54 -0400
Received: from sol.eqv.local (solmain.eqv.ru [10.173.1.2])
	by ns2.deltelecom.ru (8.14.8/8.14.7) with ESMTP id t2HA8gkH012552
	for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 13:08:43 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I'm sol sorry, but English in not my native language.

After upgrade kernel  tc lost some u32 filters

example: where is a "match ip dst 10.10.0.0/24" entries?

[root@sol ~]# tc -b tc.batch
[root@sol ~]# tc filter list dev p10p1
filter parent 1: protocol ip pref 10 u32
filter parent 1: protocol ip pref 10 u32 fh 209: ht divisor 256
filter parent 1: protocol ip pref 10 u32 fh 208: ht divisor 256
filter parent 1: protocol ip pref 10 u32 fh 207: ht divisor 256
filter parent 1: protocol ip pref 10 u32 fh 206: ht divisor 256
filter parent 1: protocol ip pref 10 u32 fh 205: ht divisor 256
filter parent 1: protocol ip pref 10 u32 fh 204: ht divisor 256
filter parent 1: protocol ip pref 10 u32 fh 203: ht divisor 256
filter parent 1: protocol ip pref 10 u32 fh 202: ht divisor 256
filter parent 1: protocol ip pref 10 u32 fh 201: ht divisor 256
filter parent 1: protocol ip pref 10 u32 fh 200: ht divisor 256
filter parent 1: protocol ip pref 10 u32 fh 100: ht divisor 256
filter parent 1: protocol ip pref 10 u32 fh 100::800 order 2048 key ht 
100 bkt 0 link 200:
   match 0a0a0000/ffffff00 at 16
     hash mask 000000ff at 16
filter parent 1: protocol ip pref 10 u32 fh 800: ht divisor 1
filter parent 1: protocol ip pref 10 u32 fh 800::800 order 2048 key ht 
800 bkt 0 link 100:
   match 0a0a0000/ffff0000 at 16
     hash mask 0000ff00 at 16
[root@sol ~]#
[root@sol ~]#
[root@sol ~]# cat tc.batch
qdisc add dev p10p1 root handle 1: htb default fffe
filter add dev p10p1 parent 1:0 protocol ip pref 10 u32
filter add dev p10p1 parent 1:0 protocol ip pref 10 handle 100: u32 
divisor 256
filter add dev p10p1 parent 1:0 protocol ip pref 10 u32 ht 800:: match 
ip dst 10.10.0.0/16 hashkey mask 0x0000ff00 at 16 link 100:
filter add dev p10p1 parent 1:0 protocol ip pref 10 handle 200: u32 
divisor 256
filter add dev p10p1 parent 1:0 protocol ip pref 10 u32 ht 100:0: match 
ip dst 10.10.0.0/24 hashkey mask 0x000000ff at 16 link 200:
filter add dev p10p1 parent 1:0 protocol ip pref 10 handle 201: u32 
divisor 256
filter add dev p10p1 parent 1:0 protocol ip pref 10 u32 ht 100:1: match 
ip dst 10.10.1.0/24 hashkey mask 0x000000ff at 16 link 201:
filter add dev p10p1 parent 1:0 protocol ip pref 10 handle 202: u32 
divisor 256
filter add dev p10p1 parent 1:0 protocol ip pref 10 u32 ht 100:2: match 
ip dst 10.10.2.0/24 hashkey mask 0x000000ff at 16 link 202:
filter add dev p10p1 parent 1:0 protocol ip pref 10 handle 203: u32 
divisor 256
filter add dev p10p1 parent 1:0 protocol ip pref 10 u32 ht 100:3: match 
ip dst 10.10.3.0/24 hashkey mask 0x000000ff at 16 link 203:
filter add dev p10p1 parent 1:0 protocol ip pref 10 handle 204: u32 
divisor 256
filter add dev p10p1 parent 1:0 protocol ip pref 10 u32 ht 100:4: match 
ip dst 10.10.4.0/24 hashkey mask 0x000000ff at 16 link 204:
filter add dev p10p1 parent 1:0 protocol ip pref 10 handle 205: u32 
divisor 256
filter add dev p10p1 parent 1:0 protocol ip pref 10 u32 ht 100:5: match 
ip dst 10.10.5.0/24 hashkey mask 0x000000ff at 16 link 205:
filter add dev p10p1 parent 1:0 protocol ip pref 10 handle 206: u32 
divisor 256
filter add dev p10p1 parent 1:0 protocol ip pref 10 u32 ht 100:6: match 
ip dst 10.10.6.0/24 hashkey mask 0x000000ff at 16 link 206:
filter add dev p10p1 parent 1:0 protocol ip pref 10 handle 207: u32 
divisor 256
filter add dev p10p1 parent 1:0 protocol ip pref 10 u32 ht 100:7: match 
ip dst 10.10.7.0/24 hashkey mask 0x000000ff at 16 link 207:
filter add dev p10p1 parent 1:0 protocol ip pref 10 handle 208: u32 
divisor 256
filter add dev p10p1 parent 1:0 protocol ip pref 10 u32 ht 100:8: match 
ip dst 10.10.8.0/24 hashkey mask 0x000000ff at 16 link 208:
filter add dev p10p1 parent 1:0 protocol ip pref 10 handle 209: u32 
divisor 256
filter add dev p10p1 parent 1:0 protocol ip pref 10 u32 ht 100:9: match 
ip dst 10.10.9.0/24 hashkey mask 0x000000ff at 16 link 209:
[root@sol ~]# uname -a
Linux sol.sol-home.local 3.18.9-200.fc21.x86_64 #1 SMP Mon Mar 9 
15:10:50 UTC 2015 x86_64 x86_64 x86_64 GNU/Linux
[root@sol ~]#



ruleset in tc.batch autogenerating by this tool 
http://sourceforge.net/projects/sc-tool/

If i copy-paste pules directly to tc command line, tc accept this line 
without any error. But rule in tc filter show is absent.

[root@sol ~]# tc filter add dev p10p1 parent 1:0 protocol ip pref 10 u32 
ht 100:9: match ip dst 10.10.9.0/24 hashkey mask 0x000000ff at 16 link 209:
[root@sol ~]# echo $?
0
[root@sol ~]# tc filter list dev p10p1
filter parent 1: protocol ip pref 10 u32
filter parent 1: protocol ip pref 10 u32 fh 209: ht divisor 256
filter parent 1: protocol ip pref 10 u32 fh 208: ht divisor 256
filter parent 1: protocol ip pref 10 u32 fh 207: ht divisor 256
filter parent 1: protocol ip pref 10 u32 fh 206: ht divisor 256
filter parent 1: protocol ip pref 10 u32 fh 205: ht divisor 256
filter parent 1: protocol ip pref 10 u32 fh 204: ht divisor 256
filter parent 1: protocol ip pref 10 u32 fh 203: ht divisor 256
filter parent 1: protocol ip pref 10 u32 fh 202: ht divisor 256
filter parent 1: protocol ip pref 10 u32 fh 201: ht divisor 256
filter parent 1: protocol ip pref 10 u32 fh 200: ht divisor 256
filter parent 1: protocol ip pref 10 u32 fh 100: ht divisor 256
filter parent 1: protocol ip pref 10 u32 fh 100::800 order 2048 key ht 
100 bkt 0 link 200:
   match 0a0a0000/ffffff00 at 16
     hash mask 000000ff at 16
filter parent 1: protocol ip pref 10 u32 fh 800: ht divisor 1
filter parent 1: protocol ip pref 10 u32 fh 800::800 order 2048 key ht 
800 bkt 0 link 100:
   match 0a0a0000/ffff0000 at 16
     hash mask 0000ff00 at 16
[root@sol ~]#


dmesg is clear.

Hoop to helping, Soloview Sergey.
