From: David Miller <davem@davemloft.net>
Subject: Re: RFC: kernel memory leak fix for af_unix datagram getpeersec
Date: Wed, 26 Jul 2006 15:49:17 -0700 (PDT)
Message-ID: <20060726.154917.124068980.davem@davemloft.net>
References: <20060726201916.GA32505@jiayuguan.watson.ibm.com>
	<1153947040.11769.208.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cxzhang@watson.ibm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jmorris@namei.org,
	catalin.marinas@gmail.com, michal.k.k.piotrowski@gmail.com,
	czhang.us@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:47784
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751811AbWGZWtL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 18:49:11 -0400
To: sds@tycho.nsa.gov
In-Reply-To: <1153947040.11769.208.camel@moss-spartans.epoch.ncsc.mil>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Smalley <sds@tycho.nsa.gov>
Date: Wed, 26 Jul 2006 16:50:40 -0400

> > diff -puN net/unix/af_unix.c~af_unix-datagram-getpeersec-ml-fix net/unix/af_unix.c
> > --- linux-2.6.18-rc2/net/unix/af_unix.c~af_unix-datagram-getpeersec-ml-fix	2006-07-22 23:01:26.000000000 -0400
> > +++ linux-2.6.18-rc2-cxzhang/net/unix/af_unix.c	2006-07-22 23:14:15.000000000 -0400
> > @@ -1323,8 +1299,9 @@ static int unix_dgram_sendmsg(struct kio
> >  	memcpy(UNIXCREDS(skb), &siocb->scm->creds, sizeof(struct ucred));
> >  	if (siocb->scm->fp)
> >  		unix_attach_fds(siocb->scm, skb);
> > -
> > -	unix_get_peersec_dgram(skb);
> > +#ifdef CONFIG_SECURITY_NETWORK
> > +	memcpy(UNIXSID(skb), &siocb->scm->sid, sizeof(u32));
> > +#endif /* CONFIG_SECURITY_NETWORK */
> 
> You want to retain the static inlines, and just update their contents,
> not replace them with embedded #ifdefs.  And this could be a direct
> assignment, right?

This is my feeling too.
