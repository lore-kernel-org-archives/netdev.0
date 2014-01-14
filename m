From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net] bonding: reset the slave's mtu when its be changed
Date: Tue, 14 Jan 2014 10:11:45 +0800
Message-ID: <52D49CE1.6040900@huawei.com>
References: <52CFDA63.8070601@huawei.com> <20140110121932.GC4132@redhat.com> <52D225A2.3070208@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:14796 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbaANCMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 21:12:03 -0500
In-Reply-To: <52D225A2.3070208@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/12 13:18, Ding Tianhong wrote:
> On 2014/1/10 20:19, Veaceslav Falico wrote:
>> On Fri, Jan 10, 2014 at 07:32:51PM +0800, Ding Tianhong wrote:
>>> All slave should have the same mtu with mastet's, and the bond do it when
>>> enslave the slave, but the user could change the slave's mtu, it will cause
>>> the master and slave have different mtu, althrough in AB mode, it does not
>>> matter if the slave is not the current slave, but in other mode, it is incorrect,
>>> so reset the slave's mtu like the master set.
>>
>> Why "net"? It's not a bugfix, it's a feature, and really discussable.
>>
>> Also, wrt the actual change - why do you think it's incorrect for slaves in
>> bonding mode other than AB to have different MTU values? I don't see any
>> reason for it, from the top of the head.
>>
> 
> Ok, I will test more situation for every mode when slave's mtu changed, I am not sure
> what will happened yet, if some links was interrupt, I thinks it is a bug. 
> 
>>>

I have test several mode for bonding when the slave mtu changed:

RR(0)	0<mtu<1500 		ok
AB(1)	0<mtu<1500		loss packets
XOR(2)	0<mtu<1500		ok
Broadcast(3)	0<mtu<1500	ok
LACP		0<mtu<1500	loss packets


so I think we should not let the mtu set for slave.
