From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next 3/4] net: switchdev: Add
 switchdev_port_bridge_getlink_deferred
Date: Mon, 9 Jan 2017 18:28:17 -0200
Message-ID: <20170109202817.GF3771@localhost.localdomain>
References: <20170109194503.10713-1-f.fainelli@gmail.com>
 <20170109194503.10713-4-f.fainelli@gmail.com>
 <20170109201135.GE3771@localhost.localdomain>
 <78bba92c-aa8e-ee1e-4b7a-3625d6f6309a@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        jiri@resnulli.us
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46812 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1764189AbdAIU2U (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 15:28:20 -0500
Content-Disposition: inline
In-Reply-To: <78bba92c-aa8e-ee1e-4b7a-3625d6f6309a@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 09, 2017 at 12:13:19PM -0800, Florian Fainelli wrote:
> On 01/09/2017 12:11 PM, Marcelo Ricardo Leitner wrote:
> > On Mon, Jan 09, 2017 at 11:45:02AM -0800, Florian Fainelli wrote:
> >> Add switchdev_port_bridge_getlink_deferred() which does a deferred
> >> object dump operation, this is required for e.g: DSA switches which
> >> typically have sleeping I/O operations which is incompatible with being
> >> in atomic context obviously.
> >>
> >> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> >> ---
> 
> >>  	struct switchdev_attr attr = {
> >>  		.orig_dev = dev,
> >> @@ -829,12 +841,49 @@ int switchdev_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
> >>  	if (err && err != -EOPNOTSUPP)
> >>  		return err;
> >>  
> >> -	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode,
> >> +	return ndo_dflt_bridge_getlink(skb, pid, seq, d, mode,
> > 
> > Was this s/dev/d/ by mistake?
> 
> No, it's not a mistake, it was made so that the function signature could
> be within 80 columns.

Right, but the change on the signature is on the chunk prior to this
one. Yet this one is not on the prototype and leads to:

.../linux/net/switchdev/switchdev.c: In function ‘__switchdev_port_bridge_getlink’:
.../linux/net/switchdev/switchdev.c:844:48: error: ‘d’ undeclared (first use in this function)
  return ndo_dflt_bridge_getlink(skb, pid, seq, d, mode,
                                                ^
.../linux/net/switchdev/switchdev.c:844:48: note: each undeclared identifier is reported only once for each function it appears in
.../linux/net/switchdev/switchdev.c:847:1: warning: control reaches end of non-void function [-Wreturn-type]
 }

  Marcelo
