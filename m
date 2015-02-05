From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch iproute2] skbedit: print action too
Date: Thu, 5 Feb 2015 10:09:30 -0800
Message-ID: <20150205100930.0d1e2ac7@urahara>
References: <1422485562-15572-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:44422 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbbBESJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 13:09:32 -0500
Received: by mail-pa0-f42.google.com with SMTP id bj1so11580278pad.1
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 10:09:32 -0800 (PST)
In-Reply-To: <1422485562-15572-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Jan 2015 14:52:42 -0800
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  tc/m_skbedit.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/tc/m_skbedit.c b/tc/m_skbedit.c
> index 36323a9..c5deee0 100644
> --- a/tc/m_skbedit.c
> +++ b/tc/m_skbedit.c
> @@ -193,7 +193,7 @@ static int print_skbedit(struct action_util *au, FILE *f, struct rtattr *arg)
>  		fprintf(f, " mark %d", *mark);
>  	}
>  
> -	fprintf(f, "\n\t index %d ref %d bind %d", p->index, p->refcnt, p->bindcnt);
> +	fprintf(f, " %s\n\t index %d ref %d bind %d", action_n2a(p->action, b1, sizeof (b1)), p->index, p->refcnt, p->bindcnt);
>  
>  	if (show_stats) {
>  		if (tb[TCA_SKBEDIT_TM]) {

It is good to show everything that is set.

The output of tc show commands should match the arguments used
to create. In this case you are printing does not match the input.

Also, I would rather see this in a separate fprintf rather than
overloading existing call.

Please cleanup and resubmit.
