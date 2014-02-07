From: Sridhar Samudrala <samudrala.sridhar@gmail.com>
Subject: Re: VLAN ID 0 with priority tagging
Date: Thu, 06 Feb 2014 21:29:58 -0800
Message-ID: <52F46F56.6070007@gmail.com>
References: <52E05901.6050601@us.ibm.com> <52F4207A.6020408@gmail.com> <52F431F6.9010605@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:51755 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750712AbaBGF3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 00:29:49 -0500
Received: by mail-ob0-f172.google.com with SMTP id vb8so3474812obc.3
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 21:29:49 -0800 (PST)
In-Reply-To: <52F431F6.9010605@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/6/2014 5:08 PM, Toshiaki Makita wrote:
> (2014/02/07 8:53), Sridhar Samudrala wrote:
>> On 1/22/2014 3:49 PM, Sridhar Samudrala wrote:
>>> I am trying to send a packet with VLAN ID 0 and non-zero priority.
>>>
>>> The VLAN interfaces are created on 2 hosts using
>>>      ip link add link eth1 eth1.0 type vlan id 0 egress-qos-map 0:2
>>>
>>> When i try to send a packet using ping/arping, on the sender side tcpdump
>>> shows that the VLAN tag is added with ID 0 and priority 2.
>>>
>>> However, the receiver is receiving the packet with vlan tag stripped.
>>>
>>> I am seeing the same behavior with multiple NICs and also with a
>>> switch in
>>> between the 2 hosts or with the 2 hosts connected over loopback cable.
>>>
>>> It looks as if the driver on the send side is stripping the tag if
>>> vlan id is 0.
>>> Is this correct behavior or a bug?
>>> Any clues on how to  get priority tagging to work with vlan id 0?
>>>
>> I sent this note a few weeks back, but i haven't seen any response so far.
>>
>> Is priority tagging with VLAN ID 0 not supported or is this a bug?
>> It looks like the NIC hardware is stripping the VLAN tag if the id is 0
>> even when VLAN tag
>> is added by the software.
> eth1.0 should be able to send frames tagged with vid 0.
> Though I don't know whether there are NICs/drivers that strip tag 0, I
> can send frames with vid 0 (with e1000e).
>
>
Good to know that it works with e1000e. I guess you are seeing the 
frames with vid 0
at the receiver.
I have tried with ixgbe and be2net and both of them seem to strip tag 0.

Thanks
Sridhar
