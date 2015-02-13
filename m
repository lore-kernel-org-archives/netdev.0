From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Possible Bug in gnet_start_copy_compat for the file,gen_stats.c
Date: Thu, 12 Feb 2015 19:01:11 -0800
Message-ID: <CAM_iQpXo+LN9LC1U_kJbn1Kjw0CRzW6VaNw5OhgCS2qteqeQXg@mail.gmail.com>
References: <54DD626C.80505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	john fastabend <john.fastabend@gmail.com>,
	standby24x7@gmail.com, rdunlap@infradead.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: nick <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54DD626C.80505@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 12, 2015 at 6:33 PM, nick <xerofoify@gmail.com> wrote:
> Greets to Everyone,
> I am wondering after running sparse on the latest mainline tree why we are not unlocking the  spinlock_bh,lock when calling the function,
> gnet_stats_start_copy_compat at the end of this function's body. Unless someone can explain to me why there is a very good reason for not
> unlocking the spinlock_bh,lock at the end of this function I will send in a patch fixing this. I am assuming this is a bug due to us infinitely
> looping in the spinlock_bh and deadlocking unless we exit this lock external to the call to the function,gnet_start_copy_compat.

The last time I looked at this, there is some place calling unlock,
you need to find it out. I don't think anyone touched it ever since
that time.

Let me know if you still can't find it. And yes, that code is kinda
messy, I _do_ have a patch to clean it up (not sent out yet).
