From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: take 2  WAS(Re: PATCH: IPSEC xfrm events
Date: Mon, 4 Apr 2005 12:26:01 +1000
Message-ID: <20050404022601.GA17293@gondor.apana.org.au>
References: <1112358278.1096.160.camel@jzny.localdomain> <20050401123554.GA3468@gondor.apana.org.au> <1112403845.1088.14.camel@jzny.localdomain> <20050402012813.GA24575@gondor.apana.org.au> <1112406164.1088.54.camel@jzny.localdomain> <20050402014619.GB24861@gondor.apana.org.au> <1112469601.1088.173.camel@jzny.localdomain> <1112538718.1096.394.camel@jzny.localdomain> <20050404005805.GA16543@gondor.apana.org.au> <1112579761.1096.412.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112579761.1096.412.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Apr 03, 2005 at 09:56:01PM -0400, jamal wrote:
> Now that you are picking on whitespaces i think we are almost there ;->

Yes I think we're getting really close now :)
 
> I think i am gonna take out any attempts to address this race above.
> It's a bug thats there already - a separate patch after this will be
> better.

OK.
 
> > > +static int xfrm_notify_sa( struct xfrm_state *x, struct km_event *c)
> > 
> > Extra space after the paren.
> > 
> > > +	int len = NLMSG_LENGTH(sizeof(struct xfrm_usersa_info));
> > 
> > Please add the additional payloads for NAT-T and the keys.
> 
> I dont think we should broadcast out keys. 

I think that decision should be made by the KM.  So you wouldn't do it
for PFKEY, but netlink should definitely do it.

For netlink we require root privileges to listen for these events.

> NAT-T - where do i look at to see what to send?

Check out dump_one_state.
 
> What is not being attached right now?

copy_to_user_tmpl

> you insulting vi? ;->

Yes unless you're using elvis :)
 
> > > -	pfkey_xfrm_policy2msg(out_skb, xp, pol->sadb_x_policy_dir-1);
> > > -
> > > -	out_hdr = (struct sadb_msg *) out_skb->data;
> > > -	out_hdr->sadb_msg_version = hdr->sadb_msg_version;
> > > -	out_hdr->sadb_msg_type = hdr->sadb_msg_type;
> > > -	out_hdr->sadb_msg_satype = 0;
> > > -	out_hdr->sadb_msg_errno = 0;
> > > -	out_hdr->sadb_msg_seq = hdr->sadb_msg_seq;
> > > -	out_hdr->sadb_msg_pid = hdr->sadb_msg_pid;
> > > -	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_ALL, sk);
> > > -	err = 0;
> > 
> > However, you do need to keep this code for the real GET case.
> 
> Get seems to a separate entry point - pfkey_get() which i didnt touch.

pfkey_get() only does states.  The code above is in pfkey_spdget().

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
