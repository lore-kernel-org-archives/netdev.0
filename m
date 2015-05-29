From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] ipv6: Fix protocol resubmission
Date: Fri, 29 May 2015 23:27:56 +0300
Message-ID: <5568CBCC.1080503@cogentembedded.com>
References: <1432929886-14259-1-git-send-email-johunt@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: Josh Hunt <johunt@akamai.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:33114 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422659AbbE2U2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 16:28:04 -0400
Received: by labpy14 with SMTP id py14so52425726lab.0
        for <netdev@vger.kernel.org>; Fri, 29 May 2015 13:28:03 -0700 (PDT)
In-Reply-To: <1432929886-14259-1-git-send-email-johunt@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/29/2015 11:04 PM, Josh Hunt wrote:

> I came across this problem while trying to use UDP encapsulation with IPv6. The
> change below fixes that, but it was not immediately apparent if there are any
> other protocols relying on this broken behavior. FWIW the behavior below now
> matches IPv4.

> Josh

    Need "Signed-off-by:" line insted of this.

> v2: Actually sets nexthdr so we can use it ;)

    Normally goes after ---, not before.

> ---

> UDP encapsulation is broken on IPv6 because it expects when it returns a negative
> value that the packet will be resubmitted to the stack with the handler corresponding
> to the return value. The check currently looks for return values > 0 and then resubmits.

> This patch fixes that check and also moves the resubmit label to take advantage of
> the return code identifying the next protocol we want to process.

> Signed-off-by: Josh Hunt <johunt@akamai.com>
> ---
>   net/ipv6/ip6_input.c |    7 ++++---
>   1 file changed, 4 insertions(+), 3 deletions(-)

> diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
> index f2e464e..e16c289 100644
> --- a/net/ipv6/ip6_input.c
> +++ b/net/ipv6/ip6_input.c
[...]
> @@ -246,9 +246,10 @@ resubmit:
>   			goto discard;
>
>   		ret = ipprot->handler(skb);
> -		if (ret > 0)
> +		if (ret < 0) {
> +			nexthdr = -ret;
>   			goto resubmit;
> -		else if (ret == 0)
> +		} else if (ret == 0)
>   			IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INDELIVERS);

    The CodingStyle dictates that all branches must have {} if at least one 
has them.

[...]

WBR, Sergei
