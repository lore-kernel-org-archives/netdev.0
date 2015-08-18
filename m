From: Andreas Schultz <aschultz@tpip.net>
Subject: [net-next]: unable to add routes to tables
Date: Tue, 18 Aug 2015 18:57:15 +0200 (CEST)
Message-ID: <1029376325.2912846.1439917035503.JavaMail.zimbra@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:60015 "EHLO mail.tpip.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753500AbbHRQ5X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 12:57:23 -0400
Received: from office.tpip.net (office.tpip.net [92.43.51.2])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.tpip.net (Postfix) with ESMTPS id 65B0E4F404
	for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 16:57:20 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by office.tpip.net (Postfix) with ESMTP id 56CFBA2F1D
	for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 18:57:16 +0200 (CEST)
Received: from office.tpip.net ([127.0.0.1])
	by localhost (office.tpip.net [127.0.0.1]) (amavisd-new, port 10032)
	with ESMTP id 4FIr4Tt9h3ZJ for <netdev@vger.kernel.org>;
	Tue, 18 Aug 2015 18:57:15 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
	by office.tpip.net (Postfix) with ESMTP id 990E8A2F31
	for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 18:57:15 +0200 (CEST)
Received: from office.tpip.net ([127.0.0.1])
	by localhost (office.tpip.net [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id SthI14RFWUC6 for <netdev@vger.kernel.org>;
	Tue, 18 Aug 2015 18:57:15 +0200 (CEST)
Received: from office.tpip.net (office.tpip.net [92.43.51.2])
	by office.tpip.net (Postfix) with ESMTP id 8488CA2F1D
	for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 18:57:15 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

It seems that the policy for adding routes to tables has changed between
Linux 4.2-rc6 and net-next.

In Linux main line (tested up to 4.2-rc6), with this main routing table:
# ip route show table main
...
172.28.0.0/24 dev vnf-xe1p0  proto kernel  scope link  src 172.28.0.16 

and an empty table 100, this works:

# ip route add 10.0.0.0/8 via 172.28.0.32 table 100 dev vnf-xe1p0

With net-next at commit d52736e24fe2e927c26817256f8d1a3c8b5d51a0, the
same command leads to an:

# ip route add 10.0.0.0/8 via 172.28.0.32 table 100 dev vnf-xe1p0
RTNETLINK answers: Resource temporarily unavailable

Is this expected behavior?

Andreas
