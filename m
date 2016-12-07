From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v2] tun: Use netif_receive_skb instead of netif_rx
Date: Wed, 7 Dec 2016 11:21:11 +0800
Message-ID: <f7d8e34b-0ceb-8fef-52f3-df4cc7d2c6c5@redhat.com>
References: <1480584880-48651-1-git-send-email-andreyknvl@google.com>
 <20161201.144357.33718747165573960.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: herbert@gondor.apana.org.au, edumazet@google.com, pmk@google.com,
        pabeni@redhat.com, mst@redhat.com, soheil@google.com,
        elfring@users.sourceforge.net, rppt@linux.vnet.ibm.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        dvyukov@google.com, kcc@google.com, syzkaller@googlegroups.com
To: David Miller <davem@davemloft.net>, andreyknvl@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161201.144357.33718747165573960.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016年12月02日 03:43, David Miller wrote:
> From: Andrey Konovalov <andreyknvl@google.com>
> Date: Thu,  1 Dec 2016 10:34:40 +0100
>
>> This patch changes tun.c to call netif_receive_skb instead of netif_rx
>> when a packet is received (if CONFIG_4KSTACKS is not enabled to avoid
>> stack exhaustion). The difference between the two is that netif_rx queues
>> the packet into the backlog, and netif_receive_skb proccesses the packet
>> in the current context.
>>
>> This patch is required for syzkaller [1] to collect coverage from packet
>> receive paths, when a packet being received through tun (syzkaller collects
>> coverage per process in the process context).
>>
>> As mentioned by Eric this change also speeds up tun/tap. As measured by
>> Peter it speeds up his closed-loop single-stream tap/OVS benchmark by
>> about 23%, from 700k packets/second to 867k packets/second.
>>
>> A similar patch was introduced back in 2010 [2, 3], but the author found
>> out that the patch doesn't help with the task he had in mind (for cgroups
>> to shape network traffic based on the original process) and decided not to
>> go further with it. The main concern back then was about possible stack
>> exhaustion with 4K stacks.
>>
>> [1] https://github.com/google/syzkaller
>>
>> [2] https://www.spinics.net/lists/netdev/thrd440.html#130570
>>
>> [3] https://www.spinics.net/lists/netdev/msg130570.html
>>
>> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>> ---
>>
>> Changes since v1:
>> - incorporate Eric's note about speed improvements in commit description
>> - use netif_receive_skb CONFIG_4KSTACKS is not enabled
> Applied to net-next, thanks!

David, looks like this commit is not in net-next.git.

Please help to check.

Thanks
