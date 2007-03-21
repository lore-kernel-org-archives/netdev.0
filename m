From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/1][PKT_CLS] Avoid multiple tree locks
Date: Wed, 21 Mar 2007 11:10:02 +0100
Message-ID: <4601047A.6050108@trash.net>
References: <1174471116.16343.10.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38838 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbXCUKKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2007 06:10:15 -0400
In-Reply-To: <1174471116.16343.10.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> Seems to have been around a while. IMO, mterial for 2.6.21 but not
> stable. I have only compile-tested but it looks right(tm).


Its harmless since its a read lock, which can be nested. I actually
don't see any need for qdisc_tree_lock at all, all changes and all
walking is done under the RTNL, which is why I've removed it in
my (upcoming) patches. I suggest to leave it as is for now so I
don't need to change the __qdisc_lookup back to qdisc_lookup in
2.6.22.

