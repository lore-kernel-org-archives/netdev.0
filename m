From: David Ahern <lxhacker68@gmail.com>
Subject: Re: [RFC PATCH net-next 1/5] tcp: Add TCP TRACE_EVENTs
Date: Wed, 17 Dec 2014 08:08:04 -0700
Message-ID: <54919C54.1050009@gmail.com>
References: <1418608606-1569264-1-git-send-email-kafai@fb.com> <1418608606-1569264-2-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Lawrence Brakmo <brakmo@fb.com>, Josef Bacik <jbacik@fb.com>,
	Kernel Team <Kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:60279 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885AbaLQPIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 10:08:10 -0500
Received: by mail-pa0-f45.google.com with SMTP id lf10so15986229pab.32
        for <netdev@vger.kernel.org>; Wed, 17 Dec 2014 07:08:10 -0800 (PST)
In-Reply-To: <1418608606-1569264-2-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/14/14 6:56 PM, Martin KaFai Lau wrote:
> +DECLARE_EVENT_CLASS(tcp,
> +	TP_PROTO(struct sock *sk),
> +	TP_ARGS(sk),
> +	TP_STRUCT__entry(
> +		__field(u8, ipv6)
> +		__array(u8, laddr, 16)
> +		__array(u8, raddr, 16)

You could store the addresses as
union {
     struct sockaddr_in      v4;
     struct sockaddr_in6     v6;
} sa;


and then use:

> +	TP_printk("local=%s:%d remote=%s:%d snd_cwnd=%u mss_cache=%u "
> +		  "ssthresh=%u srtt_us=%llu rto_ms=%u",

%pIS to print the addresses in a more readable format than what 
__print_hex will show.

I have a patch to perf (and by extension it applies to trace-cmd) to 
handle pI4, pI6 and pI6c. It readily extends to pIS.

David
