From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next RFC 1/1] net sched actions: introduce timestamp for
 first time used
Date: Wed, 18 May 2016 10:17:24 -0700
Message-ID: <CAM_iQpWXgncANS5MrBzrZiEVSbGzNptrAjisg_K2NTA-PsAMKg@mail.gmail.com>
References: <1463528337-4986-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>, nbd@nbd.name,
	baronchon@n7mm.org, Alexander Duyck <alexander.duyck@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:34541 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753420AbcERRRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 13:17:49 -0400
Received: by mail-yw0-f193.google.com with SMTP id i22so7438003ywc.1
        for <netdev@vger.kernel.org>; Wed, 18 May 2016 10:17:44 -0700 (PDT)
In-Reply-To: <1463528337-4986-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 17, 2016 at 4:38 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
> index 014f9a6..f581e01 100644
> --- a/net/sched/act_bpf.c
> +++ b/net/sched/act_bpf.c
> @@ -156,6 +156,7 @@ static int tcf_bpf_dump(struct sk_buff *skb, struct tc_action *act,
>
>         tm.install = jiffies_to_clock_t(jiffies - prog->tcf_tm.install);
>         tm.lastuse = jiffies_to_clock_t(jiffies - prog->tcf_tm.lastuse);
> +       tm.firstuse = jiffies_to_clock_t(jiffies - prog->tcf_tm.firstuse);
>         tm.expires = jiffies_to_clock_t(prog->tcf_tm.expires);


I think it is the time to add a wrapper for these tm.XX =
jiffies_to_clock_t(XXX).
