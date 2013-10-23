From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 03/16] batman-adv: add bat_orig_print API
	function
Date: Wed, 23 Oct 2013 10:27:13 -0700
Message-ID: <1382549233.22433.33.camel@joe-AO722>
References: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
 <1382544303-2694-4-git-send-email-antonio@meshcoding.com>
 <1382547630.22433.23.camel@joe-AO722>
 <20131023171810.GB2651@neomailbox.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
 Antonio Quartulli <antonio-2BnEqQcu77q1Z/+hSey0Gg@public.gmane.org>
To: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20131023171810.GB2651-rVWd3aGhH2zPj3vggD0kEA@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Wed, 2013-10-23 at 19:18 +0200, Antonio Quartulli wrote:
> On Wed, Oct 23, 2013 at 10:00:30AM -0700, Joe Perches wrote:
> > On Wed, 2013-10-23 at 18:04 +0200, Antonio Quartulli wrote:
> > > Each routing protocol has its own metric and private
> > > variables, therefore it is useful to introduce a new API
> > > for originator information printing.
> > > 
> > > This API needs to be implemented by each protocol in order
> > > to provide its specific originator table output.
> > []
> > > +static void batadv_iv_ogm_orig_print(struct batadv_priv *bat_priv,
> > > +				     struct seq_file *seq)
> > []
> > > +	seq_printf(seq, "  %-15s %s (%s/%i) %17s [%10s]: %20s ...\n",
> > > +		   "Originator", "last-seen", "#", BATADV_TQ_MAX_VALUE,
> > > +		   "Nexthop", "outgoingIF", "Potential nexthops");
> > 
> > This header printf really doesn't add much with the formatting sizes.
> > It's pretty obscure why some of these are sized and others not sized.
> > For instance: %-15s doesn't refer to a mac address size.
> > Perhaps it'd be better to just emit the fixed string just using
> > BATADV_TO_MAX_VALUE.  It'd also be easier to find via grep.
> 
> This string is printed out of a debugfs file and follows a format that we have
> been using for long time (this patch is just moving this code from one point to
> another).

I saw.

> I didn't get what you mean with BATADV_TO_MAX_VALUE (maybe you meant
> BATADV_TQ_MAX_VALUE? but even in this case I don't get it).

Yeah, TQ not TO.  Both look similar with squiggles
underneath them when using spell checking.

It's a #define, all the others are fixed strings.

Anyway, using
	seq_printf(seq, "  Originator      last-seen (#/%d)           Nexthop [outgoingIF]:   Potential nexthops ...\n",
		   BATADV_TQ_MAX_VALUE);
is probably trivially smaller overall code size too.

Your code, you decide...

cheers, Joe
