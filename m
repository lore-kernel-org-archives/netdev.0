From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH iproute2 1/1] tc: print raw qdisc handle.
Date: Mon, 7 Nov 2016 16:13:30 +0300
Message-ID: <bfcff915-d2ab-10c0-20f7-8759b317144d@cogentembedded.com>
References: <1478485019-9438-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@emojatatu.com,
        stephen@networkplumber.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: Roman Mashak <mrv@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:32994 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752797AbcKGNNc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 08:13:32 -0500
Received: by mail-lf0-f48.google.com with SMTP id c13so112847762lfg.0
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2016 05:13:31 -0800 (PST)
In-Reply-To: <1478485019-9438-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/7/2016 5:16 AM, Roman Mashak wrote:

> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>  tc/tc_qdisc.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
>
> diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
> index a63c476..9b06b8f 100644
> --- a/tc/tc_qdisc.c
> +++ b/tc/tc_qdisc.c
> @@ -238,7 +238,14 @@ int print_qdisc(const struct sockaddr_nl *who,
>  	if (n->nlmsg_type == RTM_DELQDISC)
>  		fprintf(fp, "deleted ");
>
> -	fprintf(fp, "qdisc %s %x: ", rta_getattr_str(tb[TCA_KIND]), t->tcm_handle>>16);
> +	if (!show_raw) {
> +	   fprintf(fp, "qdisc %s %x: ", rta_getattr_str(tb[TCA_KIND]),
> +			t->tcm_handle >> 16);
> +	} else {
> +	   fprintf(fp, "qdisc %s %x:[%08x] ", rta_getattr_str(tb[TCA_KIND]),
> +			t->tcm_handle >> 16, t->tcm_handle);

    The above/below code seems to indent with tabs only, why are you using spaces?

> +	}
> +
>  	if (filter_ifindex == 0)
>  		fprintf(fp, "dev %s ", ll_index_to_name(t->tcm_ifindex));
>  	if (t->tcm_parent == TC_H_ROOT)

MBR, Sergei
