From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: Re: [RFC PATCH 0/2] netdev: Add tracepoint to network/driver interface
Date: Mon, 12 Apr 2010 14:20:37 +0900
Message-ID: <4BC2ADA5.9010203@jp.fujitsu.com>
References: <4BBED951.8040406@jp.fujitsu.com> <20100409110420.GA16609@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, izumi.taku@jp.fujitsu.com,
	kaneshige.kenji@jp.fujitsu.com, davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:42588 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146Ab0DLFUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 01:20:54 -0400
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3C5KqhP021564
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Mon, 12 Apr 2010 14:20:52 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FBCE45DE53
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 14:20:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F230D45DE4E
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 14:20:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D7639E0800A
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 14:20:51 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D796E08006
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 14:20:51 +0900 (JST)
In-Reply-To: <20100409110420.GA16609@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2010/04/09 20:04), Neil Horman wrote:
> On Fri, Apr 09, 2010 at 04:37:53PM +0900, Koki Sanagi wrote:
>> These patches add tracepoints to network/driver interface.
>>
>> These tracepoints are helpful to investigate whether a packet passes or not.
>> For example, when Heart Beat is disconnected, that information is helpful
>> to investigate the cause is whether driver/device side or not.
>>
>> An output is below.
>>
>>    sshd-2443  [001] 68238.415621: netdev_start_xmit: dev=eth3 skbaddr=f3db5138 len=114
>> <idle>-0     [001] 68238.417058: netdev_receive_skb: dev=eth3 skbaddr=f3c81540 len=52
>> <idle>-0     [001] 68238.704363: netdev_receive_skb: dev=eth3 skbaddr=f3c81540 len=100
>>    sshd-2443  [001] 68238.705459: netdev_start_xmit: dev=eth3 skbaddr=f3db5138 len=114
>> <idle>-0     [001] 68238.706891: netdev_receive_skb: dev=eth3 skbaddr=f3c81540 len=52
>> <idle>-0     [001] 68238.878736: netdev_receive_skb: dev=eth3 skbaddr=f3c81540 len=100
>>    sshd-2443  [001] 68238.880361: netdev_start_xmit: dev=eth3 skbaddr=f3db5138 len=114
>>
>> As other use case I have, we can get throughput per interface with some sort of
>> perf scripts. I plan to create it.
>>
>> Thanks
>> Koki Sanagi
>>
> You can get a reasonable estimate of per-interface throughput using ethtool or
> even ifconfig in a script.  What are the tracepoints needed for that?  Don't get
> me wrong, I think these tracepoints could have some potential use thats not
> covered by other tools, I just don't see the above as a conclusive reason to add
> them.

Yeah, a script using ethtool or ifconfig can do same thing. But it must be poll
driven. By contrast this implement using tracepoint is event-driven.
It means that a record leaves on memory certainly whenever kernel crashes.
It is useful to investigate network record from dump.
This is superior to ethtool or ifconfig scripts.

