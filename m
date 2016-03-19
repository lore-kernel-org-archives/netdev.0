From: "Robin H. Johnson" <robbat2@gentoo.org>
Subject: ip-token: unable to remove a token & multi-token handling &
 concurrent use w/ EUI64/privacy
Date: Sat, 19 Mar 2016 18:53:24 +0000
Message-ID: <robbat2-20160319T175636-156562343Z@orbis-terrarum.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:33462 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751870AbcCSSxZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Mar 2016 14:53:25 -0400
Received: from grubbs.orbis-terrarum.net (localhost [127.0.0.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.gentoo.org (Postfix) with ESMTPS id A7395340ACE
	for <netdev@vger.kernel.org>; Sat, 19 Mar 2016 18:53:24 +0000 (UTC)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Playing around with IPv6 tokens, I ran into a problem:
Once you have a token set on an interface, it's impossible to remove it!

# ip token set :: dev eth0
RTNETLINK answers: Invalid argument

This is a side-effect of rejecting ipv6_addr_any in inet6_set_iftoken.

While this gets fixed, I have two related feature requests for this:
- Please make it possible to configure multiple tokens on an interface:
  Use case: Deploying local services on well-known addresses inside a
  network without explicit prefix configuration.
- Adding a token causes other address generation methods to be disabled,
  this is problematic if you wish to prefer privacy addresses for
  outbound connections.

Design suggestion:
Convert from using a single token to using a list of tokens, with an
explicit default IPv6-any-addr (::) in the list, to represent that
other address generation should ALSO take place (EUI64/privacy).
Deletion of the any-addr from the list should disable EUI64/privacy
addresses.

-- 
Robin Hugh Johnson
Gentoo Linux: Developer, Infrastructure Lead, Foundation Trustee
E-Mail     : robbat2@gentoo.org
GnuPG FP   : 11ACBA4F 4778E3F6 E4EDF38E B27B944E 34884E85
