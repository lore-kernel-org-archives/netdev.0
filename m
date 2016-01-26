From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/irda: use-after-free in ircomm_param_request
Date: Tue, 26 Jan 2016 10:13:29 -0800
Message-ID: <CAM_iQpUbCggUxAr6OpLx9CM3Gy2N4+B+2+-cgVs=Dd1z_GdL4A@mail.gmail.com>
References: <CACT4Y+bP+_KTgjksXJbjOj-CjgUgKU=dR6BVuA81kmJ9b9kJ9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+bP+_KTgjksXJbjOj-CjgUgKU=dR6BVuA81kmJ9b9kJ9g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 25, 2016 at 7:59 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> It seems that skb can be freed after skb_put() and spinlock unlock,
> but ircomm_param_request reads skb->len afterwards:
>
> int ircomm_param_request(struct ircomm_tty_cb *self, __u8 pi, int flush)
> {
>     ...
>     skb_put(skb, count);
>     spin_unlock_irqrestore(&self->spinlock, flags);
>     pr_debug("%s(), skb->len=%d\n", __func__ , skb->len);
>

This looks correct to me. We can either get rid of that debugging
print or move it under spinlock.
