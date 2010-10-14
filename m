From: Jonathan Thibault <jonathan@navigue.com>
Subject: Couple tc filter questions.
Date: Thu, 14 Oct 2010 19:31:44 -0400
Message-ID: <4CB792E0.5030704@navigue.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.navigue.com ([74.117.40.3]:38343 "EHLO mail.navigue.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751061Ab0JNXjS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Oct 2010 19:39:18 -0400
Received: from [192.168.34.187] (unknown [74.117.40.9])
	(using TLSv1 with cipher DHE-RSA-CAMELLIA256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.navigue.com (Postfix) with ESMTPSA id 6C3305298F5
	for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 19:32:05 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the lartc mailing list appears to be dead, I'll ask here and hope not to offend anyone.

1- This page:
  http://lartc.org/howto/lartc.qdisc.filters.html
States: "Also, with HTB, you should attach all filters to the root!"

Why?  Is it still true?  My setup would be a lot easier with cascading filters.  If it's just a matter of there not being any efficiency gains from cascading filters, that's fine.  If there is a risk of things exploding randomly and without notice, I'd be keen to know.  Testing shows that cascading works okay, but I haven't tried under any serious load.

2- Are filter flowid (classify) actions terminating?  Meaning if two consecutive filters would match the same packet, only the first match would ever apply and no further filter is evaluated?  Are there actions for which this isn't the case?  Intuitively and experimentally, I'd answer no but if anyone knowledgeable in the matter would care to expand on that topic I'd be grateful.  Especially considering cascading classes/filters.

Another area where termination isn't entirely clear is when using mirred and ifb devices.  I might want to send a copy of all my traffic to an ifb device, but then I would still want subsequent filters to match in the current qdisc.  In such a case, a filter that matches all traffic with a mirred action should probably not be terminating.

Maybe I'm thinking too much in terms of iptables here :P

Jonathan
