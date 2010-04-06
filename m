From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: Re: [RFC PATCH 2/2] netdev: an usage example on igb
Date: Tue, 06 Apr 2010 14:40:52 +0900
Message-ID: <4BBAC964.4070505@jp.fujitsu.com>
References: <4BB98828.5030302@jp.fujitsu.com>	 <4BB98940.5070003@jp.fujitsu.com> <1270456224.1971.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, izumi.taku@jp.fujitsu.com,
	kaneshige.kenji@jp.fujitsu.com, davem@davemloft.net,
	nhorman@tuxdriver.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	alexander.h.duyck@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:54520 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992Ab0DFFks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 01:40:48 -0400
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o365ekV6023224
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Tue, 6 Apr 2010 14:40:46 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4498445DE70
	for <netdev@vger.kernel.org>; Tue,  6 Apr 2010 14:40:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F090B45DE79
	for <netdev@vger.kernel.org>; Tue,  6 Apr 2010 14:40:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B997DE18003
	for <netdev@vger.kernel.org>; Tue,  6 Apr 2010 14:40:45 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F348E18005
	for <netdev@vger.kernel.org>; Tue,  6 Apr 2010 14:40:45 +0900 (JST)
In-Reply-To: <1270456224.1971.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2010/04/05 17:30), Eric Dumazet wrote:
> Le lundi 05 avril 2010 =C3=A0 15:54 +0900, Koki Sanagi a =C3=A9crit :
>> This patch is usage example of previous patch's buffer on igb.
>> The output is like below.
>>
>> # cat /sys/kernel/debug/ndrvbuf/igb-trace-0000\:03\:00.0/buffer
>> [  1] 50462.369207: clean_tx qidx=3D1 ntu=3D154->156
>> [  0] 50462.369241: clean_rx qidx=3D0 ntu=3D111->112
>> [  0] 50462.369250: xmit qidx=3D1 ntu=3D156->158
>> [  1] 50462.369256: clean_tx qidx=3D1 ntu=3D156->158
>> [  1] 50462.369342: clean_rx qidx=3D0 ntu=3D113->114
>> [  1] 50462.369439: clean_rx qidx=3D0 ntu=3D114->115
>>
>> This example outputs original print style, because it sets original =
print
>> function(igb_trace_read) when registered.
>>
>> register_ndrvbuf(buname, 1000000, igb_trace_read);
>>
>> If you set NULL to arg3, outputs by ndrvbuf default style.
>> If you set 0 to size(arg2), recording is disabled at first(but small=
 buffer is
>> alloced).
>> When you set non-zero to size, recording becomes enabled.
>>
>> Signed-off-by: Koki Sanagi<sanagi.koki@jp.fujitsu.com>
>> ---
>>    drivers/net/igb/Makefile    |    2 +-
>>    drivers/net/igb/igb.h       |    1 +
>>    drivers/net/igb/igb_main.c  |   10 +++++-
>>    drivers/net/igb/igb_trace.c |   81 ++++++++++++++++++++++++++++++=
+++++++++++++
>>    drivers/net/igb/igb_trace.h |   21 +++++++++++
>>    5 files changed, 113 insertions(+), 2 deletions(-)
>>
>
> This depends on NDRVBUF, yet I see no Kconfig change in this patch.
>
This igb can exist without ndrvbuf.
If ndrvbuf modules is not loaded, igb operates originally.
So this doesn't depend on ndrvbuf.
 =20


