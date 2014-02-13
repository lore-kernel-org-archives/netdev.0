From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: Re: [net-next 3/3] cfg80211: add MPLS and 802.21 classification
Date: Thu, 13 Feb 2014 11:46:01 +0100
Message-ID: <201402131146.01749.sw@simonwunderlich.de>
References: <1392202386-8826-1-git-send-email-sw@simonwunderlich.de> <1392202386-8826-4-git-send-email-sw@simonwunderlich.de> <1392205783.1868.5.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	mathias.kretschmer-8LS2qeF34IpklNlQbfROjRvVK+yQ3ZXh@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1392205783.1868.5.camel@joe-AO722>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hey Joe,

thanks for the comments!

> On Wed, 2014-02-12 at 11:53 +0100, Simon Wunderlich wrote:
> > MPLS labels may contain traffic control information, which should be
> > evaluated and used by the wireless subsystem if present.
> 
> trivial notes:
> > diff --git a/net/wireless/util.c b/net/wireless/util.c
> 
> []
> 
> > @@ -11,6 +11,7 @@
> > 
> >  #include <net/ip.h>
> >  #include <net/dsfield.h>
> >  #include <linux/if_vlan.h>
> > 
> > +#include <uapi/linux/mpls.h>
> 
> Please try not to #include uapi files.
> 

why not? The packet definition header has been put in UAPI, so I need that 
there ... or should we move that to some place else? Other protocol definition 
headers like IP, udp, tcp have been defined in uapi too the same way, so I 
figured that would be the right position.

> > @@ -710,6 +711,29 @@ unsigned int cfg80211_classify8021d(struct sk_buff
> > *skb,
> > 
> >  			return vlan_priority;
> >  	
> >  	}
> > 
> > +	if (skb_headlen(skb) >= sizeof(struct ethhdr)) {
> > +		struct ethhdr *eh = (struct ethhdr *) skb->data;
> > +		struct mpls_label_stack mpls_tmp, *mpls;
> > +
> > +		switch (eh->h_proto) {
> > +		case __constant_htons(ETH_P_MPLS_UC):
> 
> > +		case __constant_htons(ETH_P_MPLS_MC):
> __constant_ isn't necessary for these labels.
> 

OK, I will change that.

> >  	switch (skb->protocol) {
> >  	
> >  	case htons(ETH_P_IP):
> >  		dscp = ipv4_get_dsfield(ip_hdr(skb)) & 0xfc;
> 
> like this, just case htons(ETH_<FOO>) is enough.

OK.

I can rework and resend this particular patch - probably to linux wireless. If 
the other patches are ok, would you guys merge the first two patches to net-
next then?

Thanks,
    Simon
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
