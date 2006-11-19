From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH][Generic netlink]: dont send empty operational attributes
Date: Sun, 19 Nov 2006 20:54:02 +0100
Message-ID: <20061119195402.GJ8693@postel.suug.ch>
References: <4466a10611191117r3a933644scd0c4182cb08d43c@mail.gmail.com> <4466a10611191122r2bd16dbdmc35991c13dc9c92f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:2485 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S933114AbWKSTxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Nov 2006 14:53:43 -0500
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <4466a10611191122r2bd16dbdmc35991c13dc9c92f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-11-19 14:22
> On 11/19/06, jamal <hadi@cyberus.ca> wrote:
> >This is probably 2.6.19 material (a little annoyance)
> >I am testing using a new mailer - if this patch doesnt look right let me
> know.
> 
> Seems like i failed. Ok, heres the patch again..

HTML mail and application/octet-stream for the patch? :-)
Probably never made it to netdev. The patch (enclosed again)
is fine though.

Dont add operations attribute headers when the family doesnt have
any (gets annoying to see the header upon first registration
before the commands are registered)

signed-off-by: J Hadi Salim

---
commit 0dc22b960a081832e6c05b59eeefbce564354b94
tree 0659cc668f40fbe383c8d63eaa3adbec72668244
parent e030f8294a5b9f8179dae10cdbf9dcf32aa64110
author J Hadi Salim hadi@cyberus.ca <hadi@cyberus.ca> Sun, 19 Nov 2006 14:00:04 -0500
committer J Hadi Salim hadi@cyberus.ca <hadi@lilsol.(none)> Sun, 19 Nov 2006 14:00:04 -0500

 net/netlink/genetlink.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 49bc2db..9e33d5f 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -403,6 +403,9 @@ static int ctrl_fill_info(struct genl_fa
 	NLA_PUT_U32(skb, CTRL_ATTR_HDRSIZE, family->hdrsize);
 	NLA_PUT_U32(skb, CTRL_ATTR_MAXATTR, family->maxattr);
 
+	if (list_empty(&family->ops_list))
+		goto ctrl_fill_done;
+
 	nla_ops = nla_nest_start(skb, CTRL_ATTR_OPS);
 	if (nla_ops == NULL)
 		goto nla_put_failure;
@@ -429,6 +432,7 @@ static int ctrl_fill_info(struct genl_fa
 		nla_nest_end(skb, nest);
 	}
 
+ctrl_fill_done:
 	nla_nest_end(skb, nla_ops);
 
 	return genlmsg_end(skb, hdr);
