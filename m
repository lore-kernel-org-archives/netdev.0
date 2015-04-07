From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: [PATCH RFCv3 0/4] batman-adv: Unicasting multicast reports to
 querier-node only
Date: Tue,  7 Apr 2015 21:57:28 +0200
Message-ID: <1428436652-4676-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.passe0815.de ([188.40.49.9]:40787 "EHLO mail.passe0815.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753629AbbDGT5k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2015 15:57:40 -0400
Received: from mail.passe0815.de (localhost [127.0.0.1])
	by mail.passe0815.de (Postfix) with ESMTP id A262758639D
	for <netdev@vger.kernel.org>; Tue,  7 Apr 2015 21:57:36 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The last round of multicast patches send to the batman-adv mailinglist
to add support for the multicast optimizations in bridged scenarios, too,
unfortunately had one major conceptual flaw: It could lead to packet loss.
It's not sufficient to have the unicasting of reports implemented on
bridge-nodes only. Nodes without bridges need to treat reports the same
way.

The issue is described in detail here:

https://www.open-mesh.org/projects/batman-adv/wiki/Multicast-optimizations-listener-reports


I'd also be interested in what the netdev/bridge people think about
patches #1 and #2 in particular, therefore including the according mailinglists
now.

Cheers, Linus

-----

Changelog:
v3:
 * Adding Kconfig-depends and #if's
   (so basically adding similar dependancy constraints as the bridge code
    has, except that there are no depends if batman-adv gets compiled without
    multicast optimizations)
   -> the case of IPv6=M and batman-adv=y is still impossible if multicast
      optimizations are enabled; but I don't see the practical demand for that
      either - people who use IPv6 as a module will probably also want to
      use batman-adv as a module
v2:
 * various bugfixes (now runtime tested, too - should(tm) work)
 * added netdev+bridge mailinglists
