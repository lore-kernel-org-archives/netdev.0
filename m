From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH 8/8] ath10k: fix error return code
Date: Tue, 13 Jan 2015 16:16:40 +0200
Message-ID: <87ppai6a0n.fsf@kamboji.qca.qualcomm.com>
References: <1419872683-32709-1-git-send-email-Julia.Lawall@lip6.fr>
	<1419872683-32709-9-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-wireless@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<ath10k@lists.infradead.org>, <netdev@vger.kernel.org>
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419872683-32709-9-git-send-email-Julia.Lawall@lip6.fr> (Julia
	Lawall's message of "Mon, 29 Dec 2014 18:04:43 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Julia Lawall <Julia.Lawall@lip6.fr> writes:

> Return a negative error code on failure.
>
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
>
> // <smpl>
> @@
> identifier ret; expression e1,e2;
> @@
> (
> if (\(ret < 0\|ret != 0\))
>  { ... return ret; }
> |
> ret = 0
> )
> ... when != ret = e1
>     when != &ret
> *if(...)
> {
>   ... when != ret = e2
>       when forall
>  return ret;
> }
> // </smpl>
>
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Thanks, applied to ath.git.

-- 
Kalle Valo
