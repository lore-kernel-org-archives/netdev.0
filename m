From: Chris Wright <chrisw@osdl.org>
Subject: Re: [RFC][PATCH 1/3] netlink check sender
Date: Mon, 14 Feb 2005 16:17:38 -0800
Message-ID: <20050215001738.GC27645@shell0.pdx.osdl.net>
References: <20050212010109.V24171@build.pdx.osdl.net> <20050212010243.W24171@build.pdx.osdl.net> <1108385999.15437.18.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@osdl.org>, netdev@oss.sgi.com, davem@davemloft.net,
        James Morris <jmorris@redhat.com>,
        "Serge E. Hallyn" <serue@us.ibm.com>
To: Stephen Smalley <sds@epoch.ncsc.mil>
Content-Disposition: inline
In-Reply-To: <1108385999.15437.18.camel@moss-spartans.epoch.ncsc.mil>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Stephen Smalley (sds@epoch.ncsc.mil) wrote:
> On Sat, 2005-02-12 at 04:02, Chris Wright wrote:
> > ===== net/netlink/af_netlink.c 1.69 vs edited =====
> > --- 1.69/net/netlink/af_netlink.c	2005-01-21 12:25:32 -08:00
> > +++ edited/net/netlink/af_netlink.c	2005-02-11 18:05:59 -08:00
> >  int netlink_sendskb(struct sock *sk, struct sk_buff *skb, int protocol)
> >  {
> >  	struct netlink_opt *nlk;
> > -	int len = skb->len;
> > -
> > +	int err, len = skb->len;
> > +	
> >  	nlk = nlk_sk(sk);
> > +
> > +	printk("%s: %s(%d) send_check %p\n", __FUNCTION__, current->comm, current->pid, nlk->check_sender);
> > +	if (nlk->check_sender)
> > +		if ((err = nlk->check_sender(skb))) {
> > +			netlink_detachskb(sk, skb);
> > +			return err;
> > +		}
> > +
> 
> printk() is a leftover from debugging, I assume.  

Heh, yeah, just leftover gargabe.

> Why place the check_sender() call here vs. just replacing the existing
> security_netlink_send() call in netlink_sendmsg() with this new call?

That's fine, however it needs to be this late, to get the receiver looked up.
I think the sk would change in _send hook, so for RFC, I just left them
separate.  Ideal would be complete consolidation.

thanks,
-chris
-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net
