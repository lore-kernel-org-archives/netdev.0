From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: Re: [PATCH] bonding: add the sysfs interface to see RLB hash table
Date: Wed, 01 Dec 2010 14:09:21 +0900
Message-ID: <4CF5D881.1090401@jp.fujitsu.com>
References: <4CF4CB85.4010708@jp.fujitsu.com> <1291111829.2904.25.camel@edumazet-laptop> <12804.1291142278@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	shemminger@vyatta.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:57914 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735Ab0LAFJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 00:09:34 -0500
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB159X30005936
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Wed, 1 Dec 2010 14:09:33 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 32EE845DE4E
	for <netdev@vger.kernel.org>; Wed,  1 Dec 2010 14:09:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 01B1845DE4D
	for <netdev@vger.kernel.org>; Wed,  1 Dec 2010 14:09:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E80C81DB803F
	for <netdev@vger.kernel.org>; Wed,  1 Dec 2010 14:09:32 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B05371DB803A
	for <netdev@vger.kernel.org>; Wed,  1 Dec 2010 14:09:32 +0900 (JST)
In-Reply-To: <12804.1291142278@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Dear Jay Volburgh and Stephen Hemminger:

(2010/12/01 3:37), Jay Vosburgh wrote:
> Eric Dumazet<eric.dumazet@gmail.com>  wrote:
>=20
>> Le mardi 30 novembre 2010 =C3=A0 19:01 +0900, Taku Izumi a =C3=A9cri=
t :
>>> This patch provides the sysfs interface to see RLB hash table
>>> like the following:
>>>
>>> # cat /sys/class/net/bond0/bonding/rlb_hash_table
>>>
>>> SourceIP        DestinationIP   Destination MAC   DEV
>>>   10.124.196.205  10.124.196. 81 00:19:99:XX:XX:XX eth3
>>>   10.124.196.205  10.124.196.222 00:0a:79:XX:XX:XX eth0
>>>   10.124.196.205  10.124.196. 75 00:15:17:XX:XX:XX eth4
>>>   10.124.196.205  10.124.196.  1 00:21:d8:XX:XX:XX eth3
>>>   10.124.196.205  10.124.196.205 ff:ff:ff:ff:ff:ff eth0
>=20
> 	I'm reasonably sure something like this isn't going to be
> acceptable in sysfs (it's much too large).
>=20
> 	In the proc file that bonding already uses, this type of
> information isn't unreasonable, but I don't think that is the best pl=
ace
> for this, for two reasons.
>=20
> 	First, the table may have up to 256 entries.  Therefore, a
> sufficiently populated table will easily overrun the one page of spac=
e
> available to a sysfs show function or a proc seq_printf (per iteratio=
n),
> so it will have to handle that.  The current code in bonding to do it=
s
> proc file already iterates over the slaves; adding another iteration
> loop to handle this table seems overly complicated.  A well populated
> table would also make the current proc file's output rather verbose,
> particularly if the TLB table is added later.
>=20
> 	Second, it would have to hold the hash table spin lock, which
> may provide an easy way to mess with bonding (user space doing "while=
 1
> cat rlb_hash_table>  /dev/null").
>=20
> 	Therefore, I'd suggest this go into debugfs somewhere, perhaps a
> /sys/kernel/debug/bonding/rlb_hash_table (perhaps with a tlb_hash_tab=
le
> as the logical pairing for the TX side), readable only by root.
>=20
> 	Alternatively, if there are objections to using debufs, a new
> file in /proc/net/bonding could be used, although that seems cumberso=
me
> (because it would have to be named to avoid conflicts, e.g.,
> /proc/net/bonding/bond0_rlb_hash_table).
>=20

 I understand the sysfs is not the proper place. I have no objection to=
 using
debugfs. I'll try to rewrite my patch.

Taku Izumi <izumi.taku@jp.fujitsu.com>

