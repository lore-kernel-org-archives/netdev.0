From: Huang Qiang <h.huangqiang@huawei.com>
Subject: Re: [PATCH v2] netns: correctly use per-netns ipv4 sysctl_tcp_mem
Date: Thu, 19 Jul 2012 10:29:18 +0800
Message-ID: <500770FE.5080006@huawei.com>
References: <4FFE99EE.70003@huawei.com> <20120718.094137.2279894799753732191.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <glommer@parallels.com>, <netdev@vger.kernel.org>,
	<containers@lists.linux-foundation.org>, <yangzhenzhang@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:54394 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202Ab2GSCam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 22:30:42 -0400
In-Reply-To: <20120718.094137.2279894799753732191.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-7-19 0:41, David Miller wrote:

> From: Huang Qiang <h.huangqiang@huawei.com>
> Date: Thu, 12 Jul 2012 17:33:34 +0800
> 
>> From: Yang Zhenzhang <yangzhenzhang@huawei.com>
>>
>> Now, kernel allows each net namespace to independently set up its levels
>> for tcp memory pressure thresholds.
>>
>> But it seems there is a bug, as using the following steps:
>>
>> [root@host socket]# lxc-start -n test -f config /bin/bash
>> [root@net-test socket]# ip route add default via 192.168.58.2
>> [root@net-test socket]# echo 0 0 0 > /proc/sys/net/ipv4/tcp_mem
>> [root@net-test socket]# scp root@192.168.58.174:/home/tcp_mem_test .
>>
>> and it still can transport the "tcp_mem_test" file which we hope it
>> would not.
>>
>> It's because inet_init() (net/ipv4/af_inet.c)initialize the tcp_prot.sysctl_mem:
>> tcp_prot.sysctl_mem = init_net.ipv4.sysctl_tcp_mem;
>>
>> So when the protocal is TCP, sk->sk_prot->sysctl_mem(following code)
>> always use the ipv4 sysctl_tcp_mem of init_net namespace rather than
>> it's own net namespace.
>> This patch simply set "prot" equal to net->ipv4.sysctl_tcp_mem when
>> the protocol type is TCP.
>>
>> Signed-off-by: Yang Zhenzhang <yangzhenzhang@huawei.com>
>> Signed-off-by: Huang Qiang <h.huangqiang@huawei.com>
> 
> This patch doesn't apply cleanly to net-next, please respin it.
> 
> Thank you.

Ok, I will send patch v3 for net-next. Thank you!
