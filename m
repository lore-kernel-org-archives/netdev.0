From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH 4/5] ath6kl/wmi.c: eliminate possible double free
Date: Fri, 16 Nov 2012 13:17:04 +0200
Message-ID: <50A620B0.6020007@qca.qualcomm.com>
References: <1350816727-1381-1-git-send-email-Julia.Lawall@lip6.fr> <1350816727-1381-5-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <kernel-janitors@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1350816727-1381-5-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Julia,

On 10/21/2012 01:52 PM, Julia Lawall wrote:
> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> This makes two changes.  In ath6kl_wmi_cmd_send, a call to dev_kfree_skb on
> the skb argument is added to the initial sanity check to more completely
> establish the invariant that ath6kl_wmi_cmd_send owns its skb argument.
> Then, in ath6kl_wmi_sync_point, on failure of the call to
> ath6kl_wmi_cmd_send, the clearing of the local skb variable is moved up, so
> that the error-handling code at the end of the function does not free it
> again.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @r@
> identifier f,free,a;
> parameter list[n] ps;
> type T;
> expression e;
> @@
> 
> f(ps,T a,...) {
>   ... when any
>       when != a = e
>   if(...) { ... free(a); ... return ...; }
>   ... when any
> }
> 
> @@
> identifier r.f,r.free;
> expression x,a;
> expression list[r.n] xs;
> @@
> 
> * x = f(xs,a,...);
>   if (...) { ... free(a); ... return ...; }
> // </smpl>
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

I think this patch which is commited to ath6kl.git has fixed this.

commit 0616dc1f2bef563d7916c0dcedbb1bff7d9bd80b
Author: Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>
Date:   Tue Aug 14 10:10:33 2012 +0530

    ath6kl: Fix potential skb double free in ath6kl_wmi_sync_point()

    skb given to ath6kl_control_tx() is owned by ath6kl_control_tx().
    Calling function should not free the skb for error cases.
    This is found during code review.

    kvalo: fix a checkpatch warning in ath6kl_wmi_cmd_send()

    Signed-off-by: Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>
    Signed-off-by: Kalle Valo <kvalo@qca.qualcomm.com>

https://github.com/kvalo/ath6kl/commit/0616dc1f2bef563d7916c0dcedbb1bff7d9bd80b

If you have the time, I would appreciate if you could take a look and
confirm.

Kalle
