From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH V2 00/12] Add basic VLAN support to bridges
Date: Thu, 20 Dec 2012 09:00:40 +0200
Message-ID: <20121220090040.6d29d25f@pixies.home.jungo.com>
References: <1355857263-31197-1-git-send-email-vyasevic@redhat.com>
	<20121219101006.7086faef@pixies.home.jungo.com>
	<50D1CB76.50202@redhat.com>
	<20121219213716.778d6449.shmulik.ladkani@gmail.com>
	<50D21D98.7020907@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net,
	or.gerlitz@gmail.com, jhs@mojatatu.com, mst@redhat.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:48398 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934Ab2LTHIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 02:08:37 -0500
Received: by mail-wg0-f46.google.com with SMTP id dr13so1317923wgb.25
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2012 23:08:36 -0800 (PST)
In-Reply-To: <50D21D98.7020907@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vlad,

On Wed, 19 Dec 2012 15:03:36 -0500 Vlad Yasevich <vyasevic@redhat.com> wrote:
> > The port's PVID uniquely determines VID to associate with the frame
> > during _ingress_ on that port - in the case frame arrived untagged.
> >
> > This is unrelated to whether a frame having a specific VID would _egress_
> > tagged or untagged on that port.
> 
> Ahh...  I see what you mean.  You would like to separate
> ingress policy and egress policy with regard to how tags are applied...

Exactly.
Those are two different things; sometimes their configuration collide,
sometimes not.

> > The bridge constructs needed for supporting such setups are:
> > - per port: PVID
> > - per VLAN: port membership map
> > - per VLAN: port egress policy map
> 
> Ok, so from above, membership map is the exiting port_bitmap.

Ok.

> Egress policy map could be new untagged_bitmap.  We wouldn't need a tagged 
> policy map since a port can't be "in egress policy, but not in 
> membership map".

Yes, that is correct.

However I wouldn't call it "untagged_bitmap".
The name might suggest that "egress untagged" is an anomaly, where
"normal" behavior is egress tagged.
But as said, both are valid, its just a matter of configuration.

You basically need one more bit for each member port, stating
egress tagged/untagged.

> Sounds about right?  If so, I could probably work something up.

Yes, looking forward to review the code.

P.S.
Sorry for late spotting this; I don't follow net-dev regularly.
I hope to take a look at the code soon, see if I have any meaningful
comments.

Regards,
Shmulik
