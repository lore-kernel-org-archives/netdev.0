From: Andi Kleen <ak@suse.de>
Subject: Re: Fragment ID wrap workaround (read-only, untested).
Date: Thu, 15 Jul 2004 19:34:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040715173409.GA14193@wotan.suse.de>
References: <1089873416.6583.1.camel@bach>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Rusty Russell (IBM)" <rusty@au1.ibm.com>
Content-Disposition: inline
In-Reply-To: <1089873416.6583.1.camel@bach>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> +	 * other end detect ID wrap. */
> +	if (skb->sk) {
> +		unsigned int slack;
> +		struct inet_opt *inet = inet_sk(skb->sk);
> +
> +		slack = (left % mtu);
> +		if (slack)
> +			/* Shift by 8 bytes per id wrap. */
> +			len = mtu - (slack % ((inet->id >> 16) << 3));

I'm pretty sure inet->id is wrong here. You would like the counter
in the inet peer entry. inet_sk(sk)->id is just used for the pseudo
counter in TCP that only works around VJ compression bugs. It's never used
for real fragmentation.

-Andi
