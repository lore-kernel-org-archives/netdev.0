From: Julio Kriger <juliokriger@gmail.com>
Subject: Re: [PATCH] netem: fix logic bug in reorder conditional
Date: Tue, 24 May 2005 12:41:11 -0300
Message-ID: <682bc30a050524084136fa2fe3@mail.gmail.com>
References: <20050519151254.79afe7e7@dxpl.pdx.osdl.net>
	 <682bc30a05052116005bc813a2@mail.gmail.com>
	 <20050523104342.78b1032d@dxpl.pdx.osdl.net>
	 <682bc30a050523135534b38b8b@mail.gmail.com>
	 <20050523140055.127f1a9f@dxpl.pdx.osdl.net>
Reply-To: Julio Kriger <juliokriger@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        netem@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050523140055.127f1a9f@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > 2) If I set latency = 50ms and a jitter = 300ms, tabledist can give me
> > a negative number. This value is addes to cb->time_to_send, so it
> > could change it to a negative value. Should we only accept positives
> > number before add it to cb->time_to_send? or will
> > q->qdisc->enqueue(skb, q->qdisc) put the package on the queue in a
> > special way so it will be handled "before" other packages alrealy on
> > the queue but with gretaer time_to_send?
> 
> probably should bound the value to 0 before the addition, to avoid large
> wraparound problems, but since enqueue checks for for time it will work
> as long as delta less than 2^32/2.
> 

I think the value should be restricted to be positive and greater than
zero. Becuase if a negative number is allowed we will be "losing"
packages to be reordered, hence we will not be reordering, say 25%, of
packages instead we will be reordering about 15%.
In other words, packages that should be reordered will not be
reordered because its new time to send will be the same as the old
time to send.
Regards,
Julio

-- 
----------------------------
Julio Kriger
mailto:juliokriger@gmail.com
