From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net] bonding: reset the slave's mtu when its be changed
Date: Tue, 14 Jan 2014 07:03:22 +0100
Message-ID: <20140114060322.GA2430@redhat.com>
References: <52CFDA63.8070601@huawei.com>
 <20140110121932.GC4132@redhat.com>
 <52D225A2.3070208@huawei.com>
 <52D49CE1.6040900@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53597 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750962AbaANGG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 01:06:27 -0500
Content-Disposition: inline
In-Reply-To: <52D49CE1.6040900@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 10:11:45AM +0800, Ding Tianhong wrote:
>On 2014/1/12 13:18, Ding Tianhong wrote:
>> On 2014/1/10 20:19, Veaceslav Falico wrote:
>>> On Fri, Jan 10, 2014 at 07:32:51PM +0800, Ding Tianhong wrote:
>>>> All slave should have the same mtu with mastet's, and the bond do it when
>>>> enslave the slave, but the user could change the slave's mtu, it will cause
>>>> the master and slave have different mtu, althrough in AB mode, it does not
>>>> matter if the slave is not the current slave, but in other mode, it is incorrect,
>>>> so reset the slave's mtu like the master set.
>>>
>>> Why "net"? It's not a bugfix, it's a feature, and really discussable.
>>>
>>> Also, wrt the actual change - why do you think it's incorrect for slaves in
>>> bonding mode other than AB to have different MTU values? I don't see any
>>> reason for it, from the top of the head.
>>>
>>
>> Ok, I will test more situation for every mode when slave's mtu changed, I am not sure
>> what will happened yet, if some links was interrupt, I thinks it is a bug.
>>
>>>>
>
>I have test several mode for bonding when the slave mtu changed:
>
>RR(0)	0<mtu<1500 		ok
>AB(1)	0<mtu<1500		loss packets
>XOR(2)	0<mtu<1500		ok
>Broadcast(3)	0<mtu<1500	ok
>LACP		0<mtu<1500	loss packets
>
>
>so I think we should not let the mtu set for slave.

Why do you see lost packets?

>
