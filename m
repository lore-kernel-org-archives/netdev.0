From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-2.6.26] netlink: make socket filters work on netlink
Date: Tue, 01 Apr 2008 10:04:06 -0400
Message-ID: <1207058646.4424.218.camel@localhost>
References: <47EAAFEC.6000805@trash.net>	<20080331123311.64e4ca37@extreme>
	 <47F13E43.2040404@trash.net>
	 <20080331.130757.199769025.davem@davemloft.net>
	 <47F1467F.2080407@trash.net> <1207000143.4424.167.camel@localhost>
	 <47F22211.5080100@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.190]:48768 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755092AbYDAOES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 10:04:18 -0400
Received: by ti-out-0910.google.com with SMTP id 28so633022tif.23
        for <netdev@vger.kernel.org>; Tue, 01 Apr 2008 07:04:16 -0700 (PDT)
In-Reply-To: <47F22211.5080100@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-01-04 at 13:52 +0200, Patrick McHardy wrote:

> Isn't that what nlmsg_pid already contains?

would work only on the case of user<->user.
On kernel->user it is supposed to be owned by the kernel and set to 0.

OTOH, one could use the nlmsg seq as a "cookie" (since that is untouched
by the kernel) with the hope that no other process will use that same
cookie - then you can filter events based on the cookie. Note this is
only useful if you can guarantee that all processes running on a system
guarantee such uniqueness of such cookies amongst each other; which is
typically a bad assumption for a generic solution but would work.

cheers,
jamal

