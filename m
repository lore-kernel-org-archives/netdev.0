From: Chris Wright <chrisw@osdl.org>
Subject: Re: [RFC][PATCH 2/3] netlink check sender, audit
Date: Mon, 14 Feb 2005 16:11:32 -0800
Message-ID: <20050215001132.GA27645@shell0.pdx.osdl.net>
References: <20050212010109.V24171@build.pdx.osdl.net> <20050212010243.W24171@build.pdx.osdl.net> <20050212010504.X24171@build.pdx.osdl.net> <420E334B.8060805@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@osdl.org>, netdev@oss.sgi.com, davem@davemloft.net,
        jmorris@redhat.com, sds@epoch.ncsc.mil, serue@us.ibm.com
To: Pablo Neira <pablo@eurodev.net>
Content-Disposition: inline
In-Reply-To: <420E334B.8060805@eurodev.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Pablo Neira (pablo@eurodev.net) wrote:
> Chris Wright wrote:
> >+static int audit_check_sender(struct sk_buff *skb)
> >{
> >-	int err = 0;
> >+	struct nlmsghdr *nlh;
> >+	u16 msg_type;
> >+	int err = -EINVAL;
> >
> >+	if (skb->len < NLMSG_LENGTH(0))
> >+		goto out;
> >+
> >+	nlh = (struct nlmsghdr *)skb->data;
> >+	msg_type = nlh->nlmsg_type;
> 
> You're introducing some kind of check for malformed packets here as 
> well, don't you think that such thing should be done by the receiver ?

This has to be done to make the capability check meaningful, as it's
different per msg type.  Need to have a valid header to check msg type.

> I also see another option which is passing as parameter such function 
> which check for capabilities/audit stuff to my netlink_process_skb 
> function, calling it before process_msg. But in that case, the packet 
> sent by a sender that doesn't has the right to was already enqueued. I 
> understand that this is exactly what you are trying to avoid.

That's how it's done now.  The purpose of this patch is to guarantee the
check is done in the sender's context to avoid having to add values to
the control buffer to support protocol specific data (such as loginuid
in this case of audit).

thanks,
-chris
-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net
