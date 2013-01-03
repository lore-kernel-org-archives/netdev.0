From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: fix checking boundary of valid vlan id
Date: Thu, 3 Jan 2013 20:06:31 +0000
Message-ID: <1357243591.2685.2.camel@bwh-desktop.uk.solarflarecom.com>
References: <1356848931-22193-1-git-send-email-akong@redhat.com>
	 <20130103003923.GA30625@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <akong@redhat.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>,
	Netfilter Development Mailing list
	<netfilter-devel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130103003923.GA30625@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-01-03 at 01:39 +0100, Pablo Neira Ayuso wrote:
> On Sun, Dec 30, 2012 at 02:28:51PM +0800, akong@redhat.com wrote:
> > From: Amos Kong <akong@redhat.com>
> > 
> > 4096 is not a valid vlan id.
> > 
> > Signed-off-by: Amos Kong <akong@redhat.com>
> > ---
> >  net/bridge/netfilter/ebt_vlan.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/bridge/netfilter/ebt_vlan.c b/net/bridge/netfilter/ebt_vlan.c
> > index eae67bf..b279ec0 100644
> > --- a/net/bridge/netfilter/ebt_vlan.c
> > +++ b/net/bridge/netfilter/ebt_vlan.c
> > @@ -121,8 +121,8 @@ static int ebt_vlan_mt_check(const struct xt_mtchk_param *par)
> >  	 * if_vlan.h: VLAN_N_VID 4096. */
> >  	if (GET_BITMASK(EBT_VLAN_ID)) {
> >  		if (!!info->id) { /* if id!=0 => check vid range */
> > -			if (info->id > VLAN_N_VID) {
> > -				pr_debug("id %d is out of range (1-4096)\n",
> > +			if (info->id >= VLAN_N_VID) {
> > +				pr_debug("id %d is out of range (1-4095)\n",
> 
> Someone may forge frames including reserved VLAN ids.

They may find it difficult to fit the value 4096 into a 12-bit field,
though.

Ben.

> People can use ebtables to drop invalid frames, this is a firewalling
> utility after all ;-). I'm not taking these, sorry.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

