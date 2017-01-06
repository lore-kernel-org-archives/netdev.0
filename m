From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [net-next PATCH v2 5/6] i40e: Add TX and RX support in
 switchdev mode.
Date: Fri, 6 Jan 2017 11:08:58 -0800
Message-ID: <20170106110858.1598bbb8@laptop>
References: <1483466874-2962-1-git-send-email-sridhar.samudrala@intel.com>
        <1483466874-2962-6-git-send-email-sridhar.samudrala@intel.com>
        <20170105125656.GB2211@nanopsycho>
        <586EE461.2000801@intel.com>
        <20170106173035.GA1851@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
        alexander.h.duyck@intel.com, john.r.fastabend@intel.com,
        anjali.singhai@intel.com, jakub.kicinski@netronome.com,
        davem@davemloft.net, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:34375 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965660AbdAFTJX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 14:09:23 -0500
In-Reply-To: <20170106173035.GA1851@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 6 Jan 2017 18:30:35 +0100, Jiri Pirko wrote:
> >> > +	skb_dst_drop(skb);
> >> > +	dst_hold(&priv->vfpr_dst->dst);
> >> > +	skb_dst_set(skb, &priv->vfpr_dst->dst);
> >> > +	skb->dev = vsi->netdev;  
> >> This dst dance seems a bit odd to me. Why don't you just call
> >> i40e_xmit_frame_ring with an extra arg holding the needed metadata?  
> >
> >We don't have TX/RX queues associated with VFPR netdevs, so we need to set
> >the dev to PF netdev and requeue the skb.  
> 
> Still, you eventually call a function within same .c file. Using dst
> does not look right to me.

Do you mean you don't like reusing the dst_metadata to store the
representative id?  The missing patch provided the reasoning behind
this design [1].  It's mostly about being able to comfortably use the
queuing infrastructure.  Trying to push data from multiple netdevs into
single ring at driver layer is even less pretty.

[1] http://patchwork.ozlabs.org/patch/710563/
