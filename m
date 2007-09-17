From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 04/11] IB/ipoib: Verify address handle validity on send
Date: Mon, 17 Sep 2007 15:20:48 -0700
Message-ID: <ada7implyrj.fsf@cisco.com>
References: <11898132301664-git-send-email-fubar@us.ibm.com>
	<11898132322950-git-send-email-fubar@us.ibm.com>
	<1189813234208-git-send-email-fubar@us.ibm.com>
	<11898132352341-git-send-email-fubar@us.ibm.com>
	<11898132372856-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, monis@voltaire.com, monisonlists@gmail.com,
	ogerlitz@voltaire.com, jgarzik@pobox.com, davem@davemloft.net,
	general@lists.openfabrics.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:44046 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754639AbXIQWUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 18:20:51 -0400
In-Reply-To: <11898132372856-git-send-email-fubar@us.ibm.com> (Jay Vosburgh's message of "Fri, 14 Sep 2007 16:40:23 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looks fine overall, with one minor nitpick:

 > -			if (unlikely(memcmp(&neigh->dgid.raw,
 > +			if (unlikely((memcmp(&neigh->dgid.raw,
 >  					    skb->dst->neighbour->ha + 4,
 > -					    sizeof(union ib_gid)))) {
 > +					    sizeof(union ib_gid))) ||
 > +						 (neigh->dev != dev))) {

the indentation here makes this confusing to read -- I would just do:

 		} else if (neigh->ah) {
 			if (unlikely(memcmp(&neigh->dgid.raw,
 					    skb->dst->neighbour->ha + 4,
-					    sizeof(union ib_gid)))) {
+					    sizeof(union ib_gid)) ||
+				     neigh->dev != dev)) {
