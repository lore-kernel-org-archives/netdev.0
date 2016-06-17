From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [BUG] act_ife: sleeping functions called in atomic context
Date: Fri, 17 Jun 2016 07:07:34 -0400
Message-ID: <5763D9F6.6020305@mojatatu.com>
References: <1466110219-4825-1-git-send-email-khoroshilov@ispras.ru>
 <CAM_iQpWyfmUnQkQPz8dfO1NPmbdmW3AB9yWrJk6TqXyTo_DCow@mail.gmail.com>
 <57634687.3050107@mojatatu.com>
 <CAM_iQpVkFvgbYQsVB0hFKa5zVa1KCPAz=cQ7sAXdJwNM=8hpzQ@mail.gmail.com>
 <CAM_iQpXokKbXS8TiOgYqEZgLMY-01X8ebJQ-b6VrnM2x6=GFhg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, ldv-project@linuxtesting.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpXokKbXS8TiOgYqEZgLMY-01X8ebJQ-b6VrnM2x6=GFhg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-06-17 01:38 AM, Cong Wang wrote:
> On Thu, Jun 16, 2016 at 7:14 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>
>> I think we can just remove that tcf_lock, I am testing a patch now.
>
> Please try the attached patch, I will do more tests tomorrow.
>
> Thanks!
>

Cong, What tree are you using? I dont see the time aggregation patches
that I sent (and Dave took in) in your changes.

Comments:
Is GFP_ATOMIC really necessary? Thats user->kernel interface. GFP_KERNEL 
should be sufficient.
Also, it would be nice to kill the lock - but this feels like two
patches in one. 1) to fix the alloc not to be under the lock 2) to
kill said lock. Maybe split it as such for easier review.
I am using this action extensively so will be happy to test.
I think my patch is a good beginning to #1 - if you fix the forgotten
unlock and ensure we lock around updating ife fields when it exists
already (you said it in your earlier email and I thought about
that afterwards).

cheers,
jamal
