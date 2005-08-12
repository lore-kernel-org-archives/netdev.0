From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] add new iptables ipt_connbytes match
Date: Fri, 12 Aug 2005 04:52:49 +0200
Message-ID: <42FC0F01.5090802@trash.net>
References: <20050811200349.GN5353@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20050811200349.GN5353@rama.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Harald Welte wrote:
> +/* 64bit divisor, dividend and result. dynamic precision */
> +static u_int64_t div64_64(u_int64_t divisor, u_int64_t dividend)
> +{
> +	u_int64_t result = divisor;
> +
> +	if (dividend > 0xffffffff) {
> +		int first_bit = find_first_bit((unsigned long *) &dividend, sizeof(dividend));
> +		/* calculate number of bits to shift. shift exactly enough
> +		 * bits to make dividend fit in 32bits. */
> +		int num_shift = (64 - 32 - first_bit);
> +		/* first bit has to be < 32, since dividend was > 0xffffffff */
> +		result = result >> num_shift;
> +		dividend = dividend >> num_shift;
> +	}
> +
> +	do_div(divisor, dividend);
> +
> +	return divisor;
> +}

This functions looks broken. Divisor and divident are mixed up, the
shifted result variable is not used in the actual division, the
"first bit has to be < 32" assumption is wrong and num_shift is
calculated incorrectly. To find a 32-bit divisor consisting of the
most-significant 32 bits we need to find the highest bit set and
subtract 32 from this, then right-shift by that value if it is larger
than 0. I can send a fixed patch tomorrow but I'm too tired now.

> +	case IPT_CONNBYTES_WHAT_PKTS:

I would really prefer the name IPT_CONNBYTES_PKTS :)

Regards
Patrick
