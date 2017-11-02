From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next V2 1/3] tun: abstract flow steering logic
Date: Thu, 2 Nov 2017 11:43:48 +0800
Message-ID: <48c178d2-f281-c823-949c-21b79ac3ac64@redhat.com>
References: <1509445938-4345-1-git-send-email-jasowang@redhat.com>
 <1509445938-4345-2-git-send-email-jasowang@redhat.com>
 <CAF=yD-LP5kpAtL4KS2k4OjXdgy6Pe_YsUyYjW6zbCNmRzo_bdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Tom Herbert <tom@herbertland.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAF=yD-LP5kpAtL4KS2k4OjXdgy6Pe_YsUyYjW6zbCNmRzo_bdw@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年11月02日 09:11, Willem de Bruijn wrote:
> On Tue, Oct 31, 2017 at 7:32 PM, Jason Wang <jasowang@redhat.com> wrote:
>> tun now use flow caches based automatic queue steering method. This
>> may not suffice all user cases. To extend it to be able to use more
>> flow steering policy, this patch abstracts flow steering logic into
>> tun_steering_ops, then we can declare and use different methods in
>> the future.
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>   drivers/net/tun.c | 85 +++++++++++++++++++++++++++++++++++++++++--------------
>>   1 file changed, 63 insertions(+), 22 deletions(-)
>>
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index ea29da9..bff6259 100644
> The previous RFC enabled support for multiple pluggable steering
> policies. But as all can be implemented in BPF and we only plan to
> support an eBPF policy besides the legacy one, this patch is no longer
> needed. We can save a few indirect function calls.

But we should at least support two kinds of steering policy, so this is 
still needed?

And I'm not quite sure we can implement all kinds of policies through 
BPF e.g RSS or we may want to offload the queue selection to underlayer 
switch or nic .

Thanks
