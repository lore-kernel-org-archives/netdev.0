From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: Re: build breakage due to br_multicast.c referencing ipv6_dev_get_saddr()
Date: Tue, 22 Mar 2011 22:40:31 +0100
Message-ID: <1300830032-6727-1-git-send-email-linus.luessing@web.de>
References: <4D80BC5B0200007800036D85@vpn.id2.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: <davem@davemloft.net>, <shemminger@linux-foundation.org>,
	<bridge@lists.linux-foundation.org>, <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:42639 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755323Ab1CVVlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 17:41:10 -0400
In-Reply-To: <4D80BC5B0200007800036D85@vpn.id2.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> One unrelated other observation with this change of yours:
> daddr is an input argument to ipv6_dev_get_saddr(), yet
> it gets initialized only after the function was called. Is that
> really correct?
Hmm, that wasn't intentional. I tested that again and so far I still always
got the right source address. I had a little deeper look at ipv6_dev_get_saddr()
and seems like it could get racy the way it is now, so I'm attaching a patch
for that. Thanks for reporting, Jan.

And I hope I didn't cause too much inconvience with the build breakage,
didn't think of testing BRIDGE=y and IPV6=m.

Cheers, Linus
