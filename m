From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net: fix data race on sk_buff after re-cloning
Date: Thu, 17 Sep 2015 12:03:14 -0700
Message-ID: <1442516594.7946.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442515456-12390-1-git-send-email-dvyukov@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com,
	alexander.h.duyck@redhat.com, jiri@resnulli.us,
	hannes@stressinduktion.org, linus.luessing@c0d3.blue,
	willemb@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, andreyknvl@google.com,
	kcc@google.com, glider@google.com, paulmck@linux.vnet.ibm.com,
	hboehm@google.com
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442515456-12390-1-git-send-email-dvyukov@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-09-17 at 20:44 +0200, Dmitry Vyukov wrote:
> KernelThreadSanitizer (KTSAN) reported the following race (on 4.2 rc2):
> 
> ThreadSanitizer: data-race in __copy_skb_header
...

> 	if (likely(atomic_read(&skb->users) == 1))
> 		smp_rmb();
> 
> The patch contains a proposed fix.
> If it looks good to you and the scenario looks sane,
> then I will update the description and resend it.
> ---
>  net/core/skbuff.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)

I have to double check this patch, but in the case it is needed,
it would be better to not use fancy new atomic_read_acquire(),
as backporting the fix up to 3.19 (where the bug was probably added)
will require extra hassle.

atomic_read_acquire() would be fine for cleanups and new code, in next
branch.

Thanks !
