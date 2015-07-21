From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH] bonding: correct the MAC address for "follow" fail_over_mac
 policy
Date: Tue, 21 Jul 2015 15:08:28 +0800
Message-ID: <55ADEFEC.7010509@huawei.com>
References: <55A76B8A.5040804@huawei.com> <20150720.203009.2006764612728170046.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <j.vosburgh@gmail.com>, <vfalico@gmail.com>,
	<gospo@cumulusnetworks.com>, <netdev@vger.kernel.org>,
	<fengtiantian@huawei.com>, <hahaer.guo@huawei.com>,
	Li Zefan <lizefan@huawei.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20150720.203009.2006764612728170046.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015/7/21 11:30, David Miller wrote:
> From: Ding Tianhong <dingtianhong@huawei.com>
> Date: Thu, 16 Jul 2015 16:30:02 +0800
> 
>> The "follow" fail_over_mac policy is useful for multiport devices that
>> either become confused or incur a performance penalty when multiple
>> ports are programmed with the same MAC address, but the same MAC
>> address still may happened by this steps for this policy:
>>
>> 1) echo +eth0 > /sys/class/net/bond0/bonding/slaves
>>    bond0 has the same mac address with eth0, it is MAC1.
>>
>> 2) echo +eth1 > /sys/class/net/bond0/bonding/slaves
>>    eth1 is backup, eth1 has MAC2.
>>
>> 3) ifconfig eth0 down
>>    eth1 became active slave, bond will swap MAC for eth0 and eth1,
>>    so eth1 has MAC1, and eth0 has MAC2.
>>
>> 4) ifconfig eth1 down
>>    there is no active slave, and eth1 still has MAC1, eth2 has MAC2.
>>
>> 5) ifconfig eth0 up
>>    the eth0 became active slave again, the bond set eth0 to MAC1.
>>
>> Something wrong here, then if you set eth1 up, the eth0 and eth1 will have the same
>> MAC address, it will break this policy for ACTIVE_BACKUP mode.
>>
>> This patch will fix this problem by finding the old active slave and
>> swap them MAC address before change active slave.
>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> 
> Applied and queued up for -stable, thanks.

Thanks David.

hi zefan:

Could you please apply this patch to 3.4 stable tree, I think it will fix the same problem for this version.

Ding
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> .
> 
