From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] netem: fix logic bug in reorder conditional
Date: Mon, 23 May 2005 14:00:55 -0700
Message-ID: <20050523140055.127f1a9f@dxpl.pdx.osdl.net>
References: <20050519151254.79afe7e7@dxpl.pdx.osdl.net>
	<682bc30a05052116005bc813a2@mail.gmail.com>
	<20050523104342.78b1032d@dxpl.pdx.osdl.net>
	<682bc30a050523135534b38b8b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        netem@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Julio Kriger <juliokriger@gmail.com>
In-Reply-To: <682bc30a050523135534b38b8b@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 23 May 2005 17:55:35 -0300
Julio Kriger <juliokriger@gmail.com> wrote:

> Hi!
> 
> 1) Supouse I don't want reordering, so in 'tc' I don't add reorder
> option. Will this code work? The previous (on this subject) patch has
> a the following:
> 
> +       /* for compatiablity with earlier versions.
> +        * if gap is set, need to assume 100% probablity
> +        */
> +       q->reorder = ~0;
> +

If you don't want reordering, then gap = 0. so reorder is ignored.

> 
> Should it be set to 100% or 101%? 
> This "q->reorder = ~0;" mean 100%?
yes probability percentages are converted to 32-bit unsigned long scaled
value.  so 100% = 0xffffffff and 0% = 0

> 2) If I set latency = 50ms and a jitter = 300ms, tabledist can give me
> a negative number. This value is addes to cb->time_to_send, so it
> could change it to a negative value. Should we only accept positives
> number before add it to cb->time_to_send? or will
> q->qdisc->enqueue(skb, q->qdisc) put the package on the queue in a
> special way so it will be handled "before" other packages alrealy on
> the queue but with gretaer time_to_send?

probably should bound the value to 0 before the addition, to avoid large
wraparound problems, but since enqueue checks for for time it will work
as long as delta less than 2^32/2.
