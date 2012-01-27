From: David Vrabel <david.vrabel@citrix.com>
Subject: Regression: "rtnetlink: Compute and store minimum ifinfo dump size"
 breaks glibc's getifaddrs()
Date: Fri, 27 Jan 2012 12:36:47 +0000
Message-ID: <4F229A5F.4050600@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Greg Rose <gregory.v.rose@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:57645 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754604Ab2A0MhR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jan 2012 07:37:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changeset c7ac8679bec9397afe8918f788cbcef88c38da54 (rtnetlink: Compute
and store minimum ifinfo dump size) applied to 3.1 increased the maximum
size of the RTM_GETLINK message response.

glibc's getifaddrs() function uses a page sized (4 KiB) buffer for the
RTM_GETLINK response and returns a failure if the message is truncated.
This buffer is not large enough if there is a network card with many
virtual functions.

What do you recommend to resolve this regression?

David
