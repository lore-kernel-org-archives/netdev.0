From: "Denys" <denys@visp.net.lb>
Subject: more iproute2 issues (not critical)
Date: Sat, 31 Mar 2007 05:26:00 +0300
Message-ID: <20070331021401.M17326@visp.net.lb>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net> <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net> <20070322101224.3e6bb899@freekitty>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:38319 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933325AbXCaC0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2007 22:26:14 -0400
In-Reply-To: <20070322101224.3e6bb899@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While running tc monitor

defaulthost ~ #/sbin/tc2 monitor
qdisc prio 1: dev if92 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc tbf 2: dev if92 parent 1:1 rate 121600bit burst 512Kb peakrate 1280Kbit 
minburst 16Kb lat 500.0ms
filter dev if92 parent 1: protocol ip pref 5 u32 fh 800::800 order 2048 key 
ht 800 bkt 0 flowid 3:1
  match c2929918/ffffffff at 12
filter dev if92 parent 1: protocol ip pref 5 u32 fh 800::801 order 2049 key 
ht 800 bkt 0 flowid 3:1
  match c292991a/ffffffff at 12
filter dev if92 parent 1: protocol ip pref 5 u32 fh 800::802 order 2050 key 
ht 800 bkt 0 flowid 3:1
  match 02020266/ffffffff at 12
filter dev if92 parent 1: protocol ip pref 5 u32 fh 800::803 order 2051 key 
ht 800 bkt 0 flowid 3:1
  match 02020269/ffffffff at 12
filter dev if92 parent 1: protocol ip pref 5 u32 fh 800::804 order 2052 key 
ht 800 bkt 0 flowid 3:1
  match 0202026a/ffffffff at 12
filter dev if92 parent 1: protocol ip pref 10 u32 fh 801::800 order 2048 key 
ht 801 bkt 0 flowid 2:1
  match 00000000/00000000 at 16
deleted filter dev ifb0 parent 1: protocol ip pref 117 fw
deleted class htb 1:117 dev ifb0 root leaf 117: prio 0 rate 32000bit ceil 
32000bit burst 1604b cburst 1604b
class htb 1:117 dev ifb0 root prio 0 rate 32000bit ceil 32000bit burst 1604b 
cburst 1604b
qdisc sfq 117: dev ifb0 parent 1:117 limit 128p quantum 1514b perturb 5sec
filter dev ifb0 parent 1: protocol ip pref 117 fw handle 0x75 classid 1:117
qdisc ingress ffff: dev if92 parent ffff:fff1 ----------------
filter dev if92 parent ffff: protocol ip pref 5 u32 fh 800::800 order 2048 
key ht 800 bkt 0 flowid 1:1
  match 02020266/ffffffff at 16
filter dev if92 parent ffff: protocol ip pref 5 u32 fh 800::801 order 2049 
key ht 800 bkt 0 flowid 1:1
  match 02020269/ffffffff at 16
filter dev if92 parent ffff: protocol ip pref 5 u32 fh 800::802 order 2050 
key ht 800 bkt 0 flowid 1:1
  match 0202026a/ffffffff at 16
filter dev if92 parent ffff: protocol ip pref 5 u32 fh 800::803 order 2051 
key ht 800 bkt 0 flowid 1:1
  match c2929918/ffffffff at 16
filter dev if92 parent ffff: protocol ip pref 5 u32 fh 800::804 order 2052 
key ht 800 bkt 0 flowid 1:1
  match c292991a/ffffffff at 16
filter dev if92 parent ffff: protocol ip pref 10 u32 fh 801::800 order 2048 
key ht 801 bkt 0 flowid 1:1
  match 00000000/00000000 at 0
        action order 1: tablename: mangle  hook: NF_IP_PRE_ROUTING
Segmentation fault (core dumped)

Program terminated with signal 11, Segmentation fault.
#0  0x08069f38 in get_target_name (name=0xbfa397f2 "MARK") at m_ipt.c:219
219             char path[strlen(lib_dir) + sizeof ("/libipt_.so") + 
strlen(name)];

Do you need "bt full" ?
Compiled from git tree, but not latest (a little bit more fresh than latest 
release).


