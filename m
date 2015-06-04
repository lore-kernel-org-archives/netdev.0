From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: virtio-net: why not always to set avail->flags to
	VRING_AVAIL_F_NO_INTERRUPT
Date: Fri, 05 Jun 2015 05:22:01 +0930
Message-ID: <876173uu8u.fsf@rustcorp.com.au>
References: <556E9F87.7030202@huawei.com> <87k2vkuvg8.fsf@rustcorp.com.au>
	<556FB967.6010103@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org
To: Linhaifeng <haifeng.lin@huawei.com>, netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <556FB967.6010103@huawei.com>
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

Linhaifeng <haifeng.lin@huawei.com> writes:
> On 2015/6/4 9:13, Rusty Russell wrote:
>> Linhaifeng <haifeng.lin@huawei.com> writes:
>>> Hi,
>>>
>>> I'm a newbie and have a question about vring_new_virtqueue function.
>>>
>>> Why we set avail->flags to VRING_AVAIL_F_NO_INTERRUPT when no callbacks?
>>> I think we should set avail->flags to VRING_AVAIL_F_NO_INTERRUPT even if no callbacks.
>> 
>> Hi Linhaifeng,
>> 
>>         Not sure I understand your question, but I'll try to answer.
>> 
>> We don't set VRING_AVAIL_F_NO_INTERRUPT if there's a callback because we
>> want that callback called.  Otherwise callback will never be used.
>> 
>> Cheers,
>> Rusty.
>> 
>> 
>
> Hi Rusty,
>
> Thank you for your response.
>
> I mean should we set VRING_AVAIL_F_NO_INTERRUPT when virtqueue is initialized whether there is callback or not?
> As it would be set in function virtqueue_disable_cb and virtqueue_enable_cb_prepare later.

You're right, the callers could virtqueue_enable() specifically, but
I think most callers will want the virtqueue enabled immediately.

And remember, the VRING_AVAIL_F_NO_INTERRUPT is just a *hint*: the
device is allows to ignore it (this can happen due to race conditions,
for example).

Thanks,
Rusty.
