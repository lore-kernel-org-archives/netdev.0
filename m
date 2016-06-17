From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: Re: [BUG] act_ife: sleeping functions called in atomic context
Date: Fri, 17 Jun 2016 14:05:20 +0300
Message-ID: <5763D970.3030504@ispras.ru>
References: <1466110219-4825-1-git-send-email-khoroshilov@ispras.ru>
 <CAM_iQpWyfmUnQkQPz8dfO1NPmbdmW3AB9yWrJk6TqXyTo_DCow@mail.gmail.com>
 <57634687.3050107@mojatatu.com>
 <CAM_iQpVkFvgbYQsVB0hFKa5zVa1KCPAz=cQ7sAXdJwNM=8hpzQ@mail.gmail.com>
 <CAM_iQpXokKbXS8TiOgYqEZgLMY-01X8ebJQ-b6VrnM2x6=GFhg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, ldv-project@linuxtesting.org
To: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpXokKbXS8TiOgYqEZgLMY-01X8ebJQ-b6VrnM2x6=GFhg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17.06.2016 08:38, Cong Wang wrote:
> On Thu, Jun 16, 2016 at 7:14 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>
>> I think we can just remove that tcf_lock, I am testing a patch now.
> 
> Please try the attached patch, I will do more tests tomorrow.
> 
> Thanks!
> 

Looks good with two notes:
1. add_metainfo() still contains
ret = ops->alloc(mi, metaval);
that allocates memory with GFP_KERNEL.
So, I would add gfpflag argument to alloc() operation.

2. It makes sense to mention ife_mod_lock in the comment before
add_metainfo(), because ife_mod_lock is the reason to use GFP_ATOMIC there.

--
Alexey
