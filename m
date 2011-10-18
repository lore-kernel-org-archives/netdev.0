From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH 9/9] make net/core/scm.c uid comparisons user namespace
 aware
Date: Tue, 18 Oct 2011 23:22:42 +0000
Message-ID: <20111018232242.GA22950@hallyn.com>
References: <1318974898-21431-1-git-send-email-serge@hallyn.com>
 <1318974898-21431-10-git-send-email-serge@hallyn.com>
 <1318976049.2273.7.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, ebiederm@xmission.com,
	akpm@linux-foundation.org, oleg@redhat.com, richard@nod.at,
	mikevs@xs4all.net, segoon@openwall.com, gregkh@suse.de,
	dhowells@redhat.com, eparis@redhat.com,
	"Serge E. Hallyn" <serge.hallyn@canonical.com>,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1318976049.2273.7.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Joe Perches (joe@perches.com):
> On Tue, 2011-10-18 at 21:54 +0000, Serge Hallyn wrote:
> > From: "Serge E. Hallyn" <serge.hallyn@canonical.com>
> 
> Hi Serge.
> 
> Just some trivial style notes.
> 
> > Currently uids are compared without regard for the user namespace.
> > Fix that to prevent tasks in a different user namespace from
> > wrongly matching on SCM_CREDENTIALS.
> []
> > diff --git a/net/core/scm.c b/net/core/scm.c
> 
> > -static __inline__ int scm_check_creds(struct ucred *creds)
> > +static __inline__ bool uidequiv(const struct cred *src, struct ucred *tgt,
> > +			       struct user_namespace *ns)
> 
> Perhaps inline is better than __inline__ and do these
> functions really need to be marked inline at all?

Dunno, I was just sticking with the current style.

> > +{
> > +	if (src->user_ns != ns)
> > +		goto check_capable;
> > +	if (src->uid == tgt->uid || src->euid == tgt->uid ||
> > +	    src->suid == tgt->uid)
> 
> Perhaps this is less prone to typo errors and are a bit
> more readable as:
> 
> 	if (tgt->uid == src->uid ||
> 	    tgt->uid == src->euid ||
> 	    tgt->uid == src->suid)

I do like that better.

thanks,
-serge
