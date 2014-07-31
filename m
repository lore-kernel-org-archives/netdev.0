From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: ipv4: net namespace does not inherit network configurations
Date: Thu, 31 Jul 2014 09:59:12 +0800
Message-ID: <53D9A2F0.4040808@gmail.com>
References: <53D7697C.6020103@gmail.com> <CAHA+R7MC2gKeSWqR8pDDX26D-Th4BG1AveM+HseMMPjLBJuWDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hong Zhiguo <honkiko@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Tao, Yue" <Yue.Tao@windriver.com>,
	Alexandre Dietsch <alexandre.dietsch@windriver.com>,
	zhuyj <zyjzyj2000@gmail.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHA+R7MC2gKeSWqR8pDDX26D-Th4BG1AveM+HseMMPjLBJuWDw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/30/2014 01:48 AM, Cong Wang wrote:
> On Tue, Jul 29, 2014 at 2:29 AM, zhuyj <zyjzyj2000@gmail.com> wrote:
>> Hi,all
>>
>> I did a test on kernel3.16 rc6:
>>
>> root@qemu1:~# echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
>> root@qemu1:~# echo 1 > /proc/sys/net/ipv4/conf/all/forwarding
>> root@qemu1:~# ip netns list
>> root@qemu1:~# ip netns add fib1
>> root@qemu1:~# ip netns exec fib1 bash
>> root@qemu1:~# cat /proc/sys/net/ipv6/conf/all/forwarding
>> 0
>> root@qemu1:~# cat /proc/sys/net/ipv4/conf/all/forwarding
>> 1
>>
>> The behavior of ipv4 and ipv6 is very inconsistent. I checked
>> the kernel source code. I found that from this patch
>> [ipv6: fix bad free of addrconf_init_net], the above difference
>> appeared.
>>
>> Since a net namespace is independent to another. That is, there
>> is no any relationship between the net namespaces. So the behavior
>> of ipv4 is not correct.
>>
> Well, they are already independent, not shared, just that the initial
> value is duplicated from init_net for IPv4.
>
> This change might break existing applications which rely on this
> behavior, but given IPv6 change is almost the same, I think it's ok.
>
> BTW, you need to submit a patch as normal, instead of as an attachment.
>
OK. Thanks a lot.

Zhu Yanjun
