From: "James Ring" <sjr@jdns.org>
Subject: IPsec and EAGAIN
Date: Tue, 13 Jun 2006 15:51:25 +1000 (EST)
Message-ID: <61418.152.91.8.100.1150177885.squirrel@webmail.jdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from omta02sl.mx.bigpond.com ([144.140.93.154]:34200 "EHLO
	omta02sl.mx.bigpond.com") by vger.kernel.org with ESMTP
	id S932523AbWFMFvc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 01:51:32 -0400
Received: from antares.jdns.org ([61.9.204.61]) by omta02sl.mx.bigpond.com
          with ESMTP
          id <20060613055125.RVMA24931.omta02sl.mx.bigpond.com@antares.jdns.org>
          for <netdev@vger.kernel.org>; Tue, 13 Jun 2006 05:51:25 +0000
Received: from localhost
	([127.0.0.1] helo=webmail.jdns.org ident=www-data)
	by antares.jdns.org with esmtp (Exim 4.62)
	(envelope-from <sjr@jdns.org>)
	id 1Fq1oD-0005D5-ET
	for netdev@vger.kernel.org; Tue, 13 Jun 2006 15:51:25 +1000
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I have recently run into the issue where connect() returns -EAGAIN
if the remote host is on the other end of an IPsec tunnel for which no
SAD exists yet.

I have read a few threads on the topic, and it seems that the idea is to
implement a scheme similar to ARP for queueing outgoing packets until the
SAD has been negotiated by the IKE process.

I have a couple of questions: are there any patches out which solve this
problem?

Also, what is the purpose of the code in the xfrm_lookup function
(in net/xfrm_policy.c) when `flags' is true? I have applied a patch
similar to

http://sourceforge.net/mailarchive/message.php?msg_id=8621194

which gives desirable behaviour (ie. telnet appears to pause while the
racoon negotiation is performed, after which it connects just fine, no
EAGAIN).

Please CC me to any responses, I am not subscribed to the list.

Thanks for your time,
James
-- 
James Ring

