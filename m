From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 7/7] netfilter: nf_ct_helper: better logging for dropped
 packets
Date: Mon, 18 Feb 2013 17:33:14 -0800
Message-ID: <1361237594.2046.16.camel@joe-AO722>
References: <1361232651-5626-1-git-send-email-pablo@netfilter.org>
	 <1361232651-5626-8-git-send-email-pablo@netfilter.org>
	 <1361233322.2046.3.camel@joe-AO722> <20130219011109.GA6362@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130219011109.GA6362@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-02-19 at 02:11 +0100, Pablo Neira Ayuso wrote:
> On Mon, Feb 18, 2013 at 04:22:02PM -0800, Joe Perches wrote:
> > On Tue, 2013-02-19 at 01:10 +0100, pablo@netfilter.org wrote:
> > > This patch modifies the existing code to provide more specific
> > > error message in the scope of each helper to help users to debug
> > > the reason why the packet has been dropped, ie:
> > []
> > > diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
> > []
> > > @@ -100,6 +100,9 @@ struct nf_ct_helper_expectfn {
> > >  	void (*expectfn)(struct nf_conn *ct, struct nf_conntrack_expect *exp);
> > >  };
> > >  
> > > +extern void nf_ct_helper_log(struct sk_buff *skb, const struct nf_conn *,
> > > +			     const char *fmt, ...);
> > 
> > this should be declared
> > 
> > __printf(3, 4)
> > void nf_ct_helper_log(etc...)
> 
> Fixed, thanks.

Well, not really.

The new prototype is:

+extern __printf(3,4) void nf_ct_helper_log(struct sk_buff *skb,
+                                          const struct nf_conn *,
+                                          const char *fmt, ...);
+

The extern isn't necessary.
The second arg doesn't have a name.
The printf args could use a space between them.

I think this should be

__printf(3, 4)
void nf_ct_helper_log(struct sk_buff *skb, const struct nf_conn *ct,
                      const char *fmt, ...);

without the extern to be more like the prototypes that follow
it in that file.


