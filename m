From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH v3 1/5] netlink: extended ACK reporting
Date: Mon, 10 Apr 2017 17:30:18 +0200
Message-ID: <1491838218.28432.5.camel@sipsolutions.net>
References: <20170408202434.12018-1-johannes@sipsolutions.net>
         <20170408202434.12018-2-johannes@sipsolutions.net>
         <fddba2c8-3b85-d5df-81c4-ef31c459e40c@cumulusnetworks.com>
         (sfid-20170410_172609_028607_E5C0AF14)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
        Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org
To: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <fddba2c8-3b85-d5df-81c4-ef31c459e40c-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org> (sfid-20170410_172609_028607_E5C0AF14)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-04-10 at 09:26 -0600, David Ahern wrote:
> On 4/8/17 2:24 PM, Johannes Berg wrote:
> > @@ -2300,14 +2332,35 @@ void netlink_ack(struct sk_buff *in_skb,
> > struct nlmsghdr *nlh, int err)
> >  			  NLMSG_ERROR, payload, 0);
> >  	errmsg = nlmsg_data(rep);
> >  	errmsg->error = err;
> > -	memcpy(&errmsg->msg, nlh, payload > sizeof(*errmsg) ? nlh-
> > >nlmsg_len : sizeof(*nlh));
> > +	memcpy(&errmsg->msg, nlh,
> > +	       !(nlk->flags & NETLINK_F_CAP_ACK) ? nlh->nlmsg_len
> > +						 : sizeof(*nlh));
> > +
> 
> generically this makes userspace parsing more problematic: the
> parsing layer may not know if the socket option has been set to
> precisely know the size of errmsg->msg and how much data needs to be
> skipped to get to the new attributes.

Yes, I know. I'd hope that userspace can remember that per socket - I
don't see a good other way to do this.

If we insert the TLVs in front of, or instead of (with a TLV containing
it), the request message then at least libnl's debugging will need to
be changed.

As it is, I can assume that libnl will not set the CAP setting, and
everything works fine even if I don't change libnl, which makes things
easier.

Do you have any better ideas?

johannes
