From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [BUG] act_ife: sleeping functions called in atomic context
Date: Fri, 17 Jun 2016 10:31:40 -0700
Message-ID: <CAM_iQpXZA=98EKc9fTnq9W3XzuPG3zMpg22dzCpuOWVup2P=Qw@mail.gmail.com>
References: <1466110219-4825-1-git-send-email-khoroshilov@ispras.ru>
 <CAM_iQpWyfmUnQkQPz8dfO1NPmbdmW3AB9yWrJk6TqXyTo_DCow@mail.gmail.com>
 <57634687.3050107@mojatatu.com> <CAM_iQpVkFvgbYQsVB0hFKa5zVa1KCPAz=cQ7sAXdJwNM=8hpzQ@mail.gmail.com>
 <CAM_iQpXokKbXS8TiOgYqEZgLMY-01X8ebJQ-b6VrnM2x6=GFhg@mail.gmail.com> <5763D9F6.6020305@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, ldv-project@linuxtesting.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5763D9F6.6020305@mojatatu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 17, 2016 at 4:07 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 16-06-17 01:38 AM, Cong Wang wrote:
>>
>> On Thu, Jun 16, 2016 at 7:14 PM, Cong Wang <xiyou.wangcong@gmail.com>
>> wrote:
>>>
>>>
>>> I think we can just remove that tcf_lock, I am testing a patch now.
>>
>>
>> Please try the attached patch, I will do more tests tomorrow.
>>
>> Thanks!
>>
>
> Cong, What tree are you using? I dont see the time aggregation patches
> that I sent (and Dave took in) in your changes.

My patch is against -net. (I see you already figured out your patch is
missing in -net-next.)

Or are you suggesting to rebase it for -net-next? I think it fixes some real
bug so -net is better, although it is slightly large as a bug fix.

>
> Comments:
> Is GFP_ATOMIC really necessary? Thats user->kernel interface. GFP_KERNEL
> should be sufficient.

I added a read_lock(ife_mod_lock), this is why we need
GFP_ATOMIC.

Again, don't worry, this change should be in a separated patch,
you will not miss it again when I send them formally. ;)


> Also, it would be nice to kill the lock - but this feels like two
> patches in one. 1) to fix the alloc not to be under the lock 2) to
> kill said lock. Maybe split it as such for easier review.
> I am using this action extensively so will be happy to test.
> I think my patch is a good beginning to #1 - if you fix the forgotten
> unlock and ensure we lock around updating ife fields when it exists
> already (you said it in your earlier email and I thought about
> that afterwards).

Yes, it makes sense too. Your patch is smaller, if you plan to
backport it to stable, we can use your patch for -net  and -stable
and I am happy to rebase mine for -net-next.

I am fine with either way.

Thanks!
