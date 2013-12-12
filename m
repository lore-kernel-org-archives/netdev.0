From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] sch_tbf: use do_div() for 64-bit divide
Date: Thu, 12 Dec 2013 17:21:18 +0400
Message-ID: <52A9B84E.9030301@cogentembedded.com>
References: <1386814923-56180-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Yang Yingliang <yangyingliang@huawei.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:54281 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503Ab3LLNVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 08:21:16 -0500
Received: by mail-la0-f45.google.com with SMTP id eh20so306919lab.4
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 05:21:15 -0800 (PST)
In-Reply-To: <1386814923-56180-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12-12-2013 6:22, Yang Yingliang wrote:

> It's doing a 64-bit divide which is not supported
> on 32-bit architectures in psched_ns_t2l(). The
> correct way to do this is to use do_div().

> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> ---
>   net/sched/sch_tbf.c | 6 ++++--
>   1 file changed, 4 insertions(+), 2 deletions(-)

> diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
> index a44928c..887e672 100644
> --- a/net/sched/sch_tbf.c
> +++ b/net/sched/sch_tbf.c
> @@ -131,8 +131,10 @@ static u64 psched_ns_t2l(const struct psched_ratecfg *r,
>
>   	do_div(len, NSEC_PER_SEC);
>
> -	if (unlikely(r->linklayer == TC_LINKLAYER_ATM))
> -		len = (len / 53) * 48;
> +	if (unlikely(r->linklayer == TC_LINKLAYER_ATM)) {
> +		do_div(len, 53);
> +		len = len * 48;

    Why not simply len *= 48? You're coding in C, after all. :-)

WBR, Sergei
