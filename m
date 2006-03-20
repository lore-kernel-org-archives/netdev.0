From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH] scm: fold __scm_send() into scm_send()
Date: Mon, 20 Mar 2006 12:18:02 -0800
Message-ID: <20060320201802.GS15997@sorel.sous-sol.org>
References: <200603130139.k2D1dpSQ021279@shell0.pdx.osdl.net> <200603132105.32794.ioe-lkml@rameria.de> <20060313173103.7681b49d.akpm@osdl.org> <200603201244.58507.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@osdl.org>, Ingo Oeser <ioe-lkml@rameria.de>,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030223AbWCTUSu@vger.kernel.org>
To: Ingo Oeser <netdev@axxeo.de>
Content-Disposition: inline
In-Reply-To: <200603201244.58507.netdev@axxeo.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Ingo Oeser (netdev@axxeo.de) wrote:
> Hi Chris,
> 
> Andrew Morton wrote:
> > Ingo Oeser <ioe-lkml@rameria.de> wrote:
> > >
> > >  -int scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *scm)
> > >  -{
> > >  -	struct task_struct *p = current;
> > >  -	scm->creds = (struct ucred) {
> > >  -		.uid = p->uid,
> > >  -		.gid = p->gid,
> > >  -		.pid = p->tgid
> > >  -	};
> > >  -	scm->fp = NULL;
> > >  -	scm->sid = security_sk_sid(sock->sk, NULL, 0);
> > >  -	scm->seq = 0;
> > >  -	if (msg->msg_controllen <= 0)
> > >  -		return 0;
> > >  -	return __scm_send(sock, msg, scm);
> > >  -}
> > 
> > It's worth noting that scm_send() will call security_sk_sid() even if
> > (msg->msg_controllen <= 0).
> 
> Chris, do you know if this is needed in this case?

This whole thing is looking broken.  I'm still trying to find the original
patch which caused the series of broken patches on top.

thanks,
-chris
