From: Benjamin Poirier <bpoirier@suse.de>
Subject: Re: [PATCH net/stable] gro: reset vlan_tci on reuse
Date: Sat, 26 Nov 2011 20:01:05 -0500
Message-ID: <20111127010105.GA13428@gort.synalogic.ca>
References: <1322320749-8055-1-git-send-email-bpoirier@suse.de>
 <20111126155202.GA8467@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	stable@vger.kernel.org, Jesse Gross <jesse@nicira.com>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:62708 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755205Ab1K0A7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2011 19:59:05 -0500
Content-Disposition: inline
In-Reply-To: <20111126155202.GA8467@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/11/26 07:52, Greg KH wrote:
> On Sat, Nov 26, 2011 at 10:19:09AM -0500, Benjamin Poirier wrote:
> > This one liner is part of upstream
> > commit 3701e51382a026cba10c60b03efabe534fba4ca4
> > 
> > and it is in the same vein as
> > commit 66c46d741e2e60f0e8b625b80edb0ab820c46d7a
> > commit 6d152e23ad1a7a5b40fef1f42e017d66e6115159
> > 
> > which are already in -stable.
> > 
> > For drivers using the vlan_gro_frags() interface, a packet with invalid tci
> > leads to GRO_DROP and napi_reuse_skb(). The skb has to be sanitized before
> > being reused or we'll send skb's with invalid vlan_tci up the stack where
> > they're not expected.
> > 
> > Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
> > Cc: Jesse Gross <jesse@nicira.com>
> > 
> > ---
> > 
> > Please note, reusing skb's with an invalid vlan_tci can cause panics on
> > 2.6.32.y -stable kernels.
> 
> You forgot to mention what stable kernel tree(s) you want this patch
> applied to.  And why can't I just take all of
> 3701e51382a026cba10c60b03efabe534fba4ca4? (hint, when refering to git
> commit ids, please put the description of what they are in () after them
> so we have a hint and don't have to dig through a git tree to find
> them.)

Ah, thank you for spelling it out, I was clueless after re-reading
kernel_stable_rules.txt

> > This one liner is part of upstream
> > commit 3701e51382a026cba10c60b03efabe534fba4ca4
Author: Jesse Gross <jesse@nicira.com>
vlan: Centralize handling of hardware acceleration.

> > 
> > and it is in the same vein as
> > commit 66c46d741e2e60f0e8b625b80edb0ab820c46d7a
Author: Herbert Xu <herbert@gondor.apana.org.au>
gro: Reset dev pointer on reuse

> > commit 6d152e23ad1a7a5b40fef1f42e017d66e6115159
Author: Andy Gospodarek <andy@greyhouse.net>
gro: reset skb_iif on reuse

Jesse's upstream commit is a rework of the hardware assisted vlan
tagging driver interface, and as such doesn't classify for -stable
inclusion. The fix that is needed just happens to be part of that commit
but can work independently of the rest -- I guess they could've been
separate commits from the start.

The vlan_gro_frags() interface was introduced in 2.6.29 and Jesse's
commit went in 2.6.37. -stable kernels in between can make use of the
fix which I believe makes it applicable to 2.6.32.y and .33.y given the
-stable branches that seem to be getting updates at this time.

> 
> Also, I need David's ack before I can take this, or any other network
> patch, for the stable tree.

cc'ed.

Thanks,
-Benjamin
