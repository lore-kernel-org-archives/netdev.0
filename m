From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] iproute2 -- add fwmarkmask
Date: Mon, 20 Feb 2006 18:03:04 +0100
Message-ID: <43F9F648.1060803@trash.net>
References: <23395.1140452828@sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	shemminger@osdl.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Michael Richardson <mcr@sandelman.ottawa.on.ca>
In-Reply-To: <23395.1140452828@sandelman.ottawa.on.ca>
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

Michael Richardson wrote:
> -	if (tb[RTA_PROTOINFO]) {
> -		fprintf(fp, "fwmark %#x ", *(__u32*)RTA_DATA(tb[RTA_PROTOINFO]));
> +	if (tb[RTA_FWMARK]) {
> +		__u32 value = *(__u32*)RTA_DATA(tb[RTA_PROTOINFO]);
> +		if (tb[RTA_FWMARK_MASK]) {
> +			__u32 mask;
> +			mask=*(__u32*)RTA_DATA(tb[RTA_FWMARK_MASK]);
> +			fprintf(fp, "fwmark %#x&%#x ", value, mask);

The normal way to display masks is with a "/". Also I think it shouldn't
display the default mask to avoid breaking scripts that parse the
output.
> +		} else if (strcmp(*argv, "fwmarkmask") == 0) {
> +			__u32 fwmarkmask;
> +			NEXT_ARG();
> +			if (get_u32(&fwmarkmask, *argv, 0))
> +				invarg("fwmarkmask value is invalid\n", *argv);
> +			addattr32(&req.n, sizeof(req), RTA_FWMARK_MASK, fwmarkmask);

ip should be able to parse its own output, and it would also look nicer
if I could just say "fwmark 0x1/32". fwmarkmask is really an incredible
ugly expression :)
