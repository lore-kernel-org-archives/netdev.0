From: Rusty Russell <rusty@rustcorp.com.au>
Subject: RE: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Thu, 27 Apr 2006 13:40:26 +1000
Message-ID: <1146109226.11864.37.camel@localhost.localdomain>
References: <54AD0F12E08D1541B826BE97C98F99F143AE6C@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, kelly@au1.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:37600 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S932354AbWD0Dky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2006 23:40:54 -0400
To: Caitlin Bestler <caitlinb@broadcom.com>
In-Reply-To: <54AD0F12E08D1541B826BE97C98F99F143AE6C@NT-SJCA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-04-26 at 12:30 -0700, Caitlin Bestler wrote:
> David S. Miller wrote:
> 
> > 
> > I personally think allowing sockets to trump firewall rules
> > is an acceptable relaxation of the rules in order to simplify
> > the implementation.
> 
> I agree.  I have never seen a set of netfilter rules that
> would block arbitrary packets *within* an established connection.

Intelligent or no, this does happen.  More importantly, people rely on
packet counters.  Basically I don't think we can "relax" our firewall
implementation and retain trust 8(

I started thinking about this back in January.  We could force
everything through the "slow" path when something is registered with
netfilter (similarly raw sockets, bonding, divert).  Or, we could delay
LOCAL_IN hook processing until we get to socket receive.

Delaying netfilter hook processing won't work for intelligent NICs that
write straight to mmapped buffers, but we could make that CAP_NET_RAW.

We *used* to have an nf_cache mechanism to determine exactly when the
netfilter hooks cared about a packet, but it was never used and was hard
to reconcile with connection-tracking timeouts...

Cheers,
Rusty.
-- 
 ccontrol: http://ozlabs.org/~rusty/ccontrol

