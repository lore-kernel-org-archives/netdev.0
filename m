From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH net-next] ipv6: send Change Status Report after DAD is
 completed
Date: Thu, 16 Jan 2014 10:21:54 -0200
Message-ID: <20140116122154.GK5359@plex.lan>
References: <1389813008-23851-1-git-send-email-fbl@redhat.com>
 <52D7C0BA.7010908@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7874 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752430AbaAPMUr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 07:20:47 -0500
Content-Disposition: inline
In-Reply-To: <52D7C0BA.7010908@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 16, 2014 at 12:21:30PM +0100, Daniel Borkmann wrote:
> On 01/15/2014 08:10 PM, Flavio Leitner wrote:
> >The RFC 3810 defines two type of messages for multicast
> >listeners. The "Current State Report" message, as the name
> >implies, refreshes the *current* state to the querier.
> >Since the querier sends Query messages periodically, there
> >is no need to retransmit the report.
> >
> >On the other hand, any change should be reported immediately
> >using "State Change Report" messages. Since it's an event
> >triggered by a change and that it can be affected by packet
> >loss, the rfc states it should be retransmitted [RobVar] times
> >to make sure routers will receive timely.
> >
> >Currently, we are sending "Current State Reports" after
> >DAD is completed.  Before that, we send messages using
> >unspecified address (::) which should be silently discarded
> >by routers.
> >
> >This patch changes to send "State Change Report" messages
> >after DAD is completed fixing the behavior to be RFC compliant
> >and also to pass TAHI IPv6 testsuite.
> >
> >Signed-off-by: Flavio Leitner <fbl@redhat.com>
> >---
> >  net/ipv6/mcast.c | 64 ++++++++++++++++++++++++++++++++++----------------------
> >  1 file changed, 39 insertions(+), 25 deletions(-)
> >
> >diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> >index 99cd65c..8ac17f5 100644
> >--- a/net/ipv6/mcast.c
> >+++ b/net/ipv6/mcast.c
> >@@ -1493,7 +1493,7 @@ static struct sk_buff *add_grhead(struct sk_buff *skb, struct ifmcaddr6 *pmc,
> >  	skb_tailroom(skb)) : 0)
> >
> >  static struct sk_buff *add_grec(struct sk_buff *skb, struct ifmcaddr6 *pmc,
> >-	int type, int gdeleted, int sdeleted)
> >+	int type, int gdeleted, int sdeleted, int crsend)
> 
> Maybe we should convert the last three to 'bool' at some point in time?

I'd say so.

> Nit: argument indent

Ok, will fix in the v2
[...]
> >+	if (MLD_V1_SEEN(idev))
> >+		return;
> 
> $ git grep -n MLD_V1_SEEN
> $
> 
> I believe I have removed that macro some time ago. ;)
> 
> I presume you mean rather: mld_in_v1_mode(idev)

Oops, branched from the wrong (old) point here.
I will send a v2.

Thanks,
fbl
