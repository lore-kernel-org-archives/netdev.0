From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio_net: invoke softirqs after __napi_schedule
Date: Wed, 16 May 2012 23:40:53 -0400 (EDT)
Message-ID: <20120516.234053.248044235713127837.davem@davemloft.net>
References: <20120516075712.GA2921@redhat.com> <87vcjvzdlm.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
To: rusty@rustcorp.com.au
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <87vcjvzdlm.fsf@rustcorp.com.au>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 17 May 2012 13:02:53 +0930

> On Wed, 16 May 2012 10:57:13 +0300, "Michael S. Tsirkin" <mst@redhat.com> wrote:
>> __napi_schedule might raise softirq but nothing
>> causes do_softirq to trigger, so it does not in fact
>> run. As a result,
>> the error message "NOHZ: local_softirq_pending 08"
>> sometimes occurs during boot of a KVM guest when the network service is
>> started and we are oom:
>> 
>>   ...
>>   Bringing up loopback interface:  [  OK  ]
>>   Bringing up interface eth0:
>>   Determining IP information for eth0...NOHZ: local_softirq_pending 08
>>    done.
>>   [  OK  ]
>>   ...
>> 
>> Further, receive queue processing might get delayed
>> indefinitely until some interrupt triggers:
>> virtio_net expected napi to be run immediately.
>> 
>> One way to cause do_softirq to be executed is by
>> invoking local_bh_enable(). As __napi_schedule is
>> normally called from bh or irq context, this
>> seems to make sense: disable bh before __napi_schedule
>> and enable afterwards.
>> 
>> Reported-by: Ulrich Obergfell <uobergfe@redhat.com>
>> Tested-by: Ulrich Obergfell <uobergfe@redhat.com>
>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
 ...
> Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Michael, you're best to submit this directly to Linus as I just
made what I hope is my last push to him for 3.4 today.
