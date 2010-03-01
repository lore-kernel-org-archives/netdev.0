From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] accounting for socket backlog
Date: Mon, 01 Mar 2010 04:12:40 +0100
Message-ID: <1267413160.9082.120.camel@edumazet-laptop>
References: <1267067593.16986.1583.camel@debian>
	 <1267097080.2822.14.camel@edumazet-laptop>
	 <1267151683.16986.1646.camel@debian>
	 <1267189945.2822.1572.camel@edumazet-laptop>
	 <1267409827.23196.44.camel@debian>
	 <1267410585.9082.115.camel@edumazet-laptop>
	 <1267412604.23196.53.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Shi, Alex" <alex.shi@intel.com>
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:39247 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753526Ab0CADMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 22:12:45 -0500
Received: by bwz1 with SMTP id 1so91746bwz.21
        for <netdev@vger.kernel.org>; Sun, 28 Feb 2010 19:12:43 -0800 (PST)
In-Reply-To: <1267412604.23196.53.camel@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 01 mars 2010 =C3=A0 11:03 +0800, Zhu Yi a =C3=A9crit :

> This is my original plan. But davem just mentioned we have to prevent
> from maliciously send frames, that means all protocols using backlog.
> That makes me consider if I should put the check to the generic path.
>=20

Sure, check could be done in sk_add_backlog() (including the
atomic_inc(&sk->sk_drops); and kfree_skb(skb);), but make sure a status
is returned so that we can increment SNMP counters at protocol level.



