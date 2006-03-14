From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] scm: fold __scm_send() into scm_send()
Date: Mon, 13 Mar 2006 17:31:03 -0800
Message-ID: <20060313173103.7681b49d.akpm@osdl.org>
References: <200603130139.k2D1dpSQ021279@shell0.pdx.osdl.net>
	<20060312.180802.13404061.davem@davemloft.net>
	<200603132105.32794.ioe-lkml@rameria.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752013AbWCNBdh@vger.kernel.org>
To: Ingo Oeser <ioe-lkml@rameria.de>
In-Reply-To: <200603132105.32794.ioe-lkml@rameria.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Oeser <ioe-lkml@rameria.de> wrote:
>
>  -int scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *scm)
>  -{
>  -	struct task_struct *p = current;
>  -	scm->creds = (struct ucred) {
>  -		.uid = p->uid,
>  -		.gid = p->gid,
>  -		.pid = p->tgid
>  -	};
>  -	scm->fp = NULL;
>  -	scm->sid = security_sk_sid(sock->sk, NULL, 0);
>  -	scm->seq = 0;
>  -	if (msg->msg_controllen <= 0)
>  -		return 0;
>  -	return __scm_send(sock, msg, scm);
>  -}

It's worth noting that scm_send() will call security_sk_sid() even if
(msg->msg_controllen <= 0).

If that test is likely to be true with any frequency then perhaps we can
optimise things...
