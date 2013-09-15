From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: Re: [PATCH v2.39 6/7] datapath: Break out deacceleration
 portion of vlan_push
Date: Sun, 15 Sep 2013 11:32:56 -0500
Message-ID: <20130915163256.GB14042@verge.net.au>
References: <1378711207-29890-1-git-send-email-horms@verge.net.au>
	<1378711207-29890-7-git-send-email-horms@verge.net.au>
	<CAEP_g=_ZQ6hNpxoHm6t3N=PxA+3WTrvNegL514j0R3GDM5C92A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAEP_g=_ZQ6hNpxoHm6t3N=PxA+3WTrvNegL514j0R3GDM5C92A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 13, 2013 at 03:07:12PM -0700, Jesse Gross wrote:
> On Mon, Sep 9, 2013 at 12:20 AM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> > diff --git a/datapath/actions.c b/datapath/actions.c
> > index 30ea1d2..6741d81 100644
> > --- a/datapath/actions.c
> > +++ b/datapath/actions.c
> > @@ -105,22 +105,29 @@ static int pop_vlan(struct sk_buff *skb)
> >         return 0;
> >  }
> >
> > -static int push_vlan(struct sk_buff *skb, const struct ovs_action_push_vlan *vlan)
> > +/* push down current VLAN tag */
> > +static struct sk_buff *put_vlan(struct sk_buff *skb)
> 
> This never changes the skb, right? Can we simplify things and just
> return an error code?

Yes, I think that should be possible.
