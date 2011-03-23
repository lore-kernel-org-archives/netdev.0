From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH v2] net/unix: Add secdata to unix_stream msgs
Date: Wed, 23 Mar 2011 11:57:27 -0400
Message-ID: <1300895847.28871.13.camel@unknown001a4b0c2895>
References: <1300840717-4413-1-git-send-email-pekane52@gmail.com>
	 <20110322.193206.28821045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pekane52@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, cxzhang@watson.ibm.com, sds@tycho.nsa.gov,
	jmorris@namei.org, eparis@parisplace.org, paul.moore@hp.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110322.193206.28821045.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-03-22 at 19:32 -0700, David Miller wrote:
> From: Pat Kane <pekane52@gmail.com>
> Date: Tue, 22 Mar 2011 19:38:37 -0500
> 
> > The unix_dgram routines add secdata to socket messages,
> > but the unix_stream routines do not. I have added the
> > two missing lines of code.
> > 
> > Signed-off-by: Pat Kane <pekane52@gmail.com>
> 
> The security hooks appear to be only intended to operate on datagram
> sockets, and as such I think the omission of UNIX stream sockets was
> very much on purpose.
> 
> The SELINUX hook implementations even have "_dgram()" in their names.
> 
> Catherine Zhang added to CC: as she last made modifications to these
> hooks.

And I'll add Paul Moore as I think he understands the intersection
of /net and /security better than anyone.

> 
> > diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> > index 1663e1a..8753cdd 100644
> > --- a/net/unix/af_unix.c
> > +++ b/net/unix/af_unix.c
> > @@ -1642,6 +1642,8 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
> >  		max_level = err + 1;
> >  		fds_sent = true;
> >  
> > +		unix_get_secdata(siocb->scm, skb);
> > +
> >  		err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
> >  		if (err) {
> >  			kfree_skb(skb);
> > @@ -1930,6 +1932,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
> >  		} else {
> >  			/* Copy credentials */
> >  			scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).cred);
> > +			unix_set_secdata(siocb->scm, skb);
> >  			check_creds = 1;
> >  		}
> >  
> > -- 
> > 1.7.1
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
