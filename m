From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next] net_sched: refactor out tcf_exts
Date: Mon, 06 Oct 2014 07:09:49 -0400
Message-ID: <5432787D.90808@mojatatu.com>
References: <1412376709-25564-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:36933 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751289AbaJFLJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 07:09:58 -0400
Received: by mail-ig0-f177.google.com with SMTP id a13so2475059igq.16
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 04:09:57 -0700 (PDT)
In-Reply-To: <1412376709-25564-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/14 18:51, Cong Wang wrote:
> As Jamal pointed it out, tcf_exts is really unnecessary,
> we can definitely refactor it out without losing any functionality.
> This could also remove an indirect layer which makes the code
> much easier to read.
>
> This patch:
>
> 1) moves exts->action and exts->police into tp->ops, since they
> are statically assigned
>
> 2) moves exts->actions list head out
>
> 3) removes exts->type, act->type does the same thing
>
> 4) renames tcf_exts_*() functions to tcf_act_*()
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks for doing the work Cong.
I noticed John points to an issue in his testing; but
please add my:
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

I will start sending incremental patches to iproute2 to slowly get
rid of direct police interfacing which will allow us to get rid of
.police dereference altogether.
It was a mistake not to do it years ago.
One way to accelerate it right now is to log a "deprecated"
message everytime someone uses TCA_XXX_POLICE attributes.

cheers,
jamal
