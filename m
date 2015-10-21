From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] net: try harder to not reuse ifindex when moving
 interfaces
Date: Wed, 21 Oct 2015 16:46:13 +0200
Message-ID: <20151021164613.24650836@griffin>
References: <294c7a9df554506e684adbeb9bbed070e6fed260.1444993627.git.jbenc@redhat.com>
	<20151021.074332.1709904332480699231.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thaller@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40916 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751996AbbJUOqQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2015 10:46:16 -0400
In-Reply-To: <20151021.074332.1709904332480699231.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Oct 2015 07:43:32 -0700 (PDT), David Miller wrote:
> Fix the real problem, then come talk to us.

I don't think the real problem is fixable, given that any kind of
unique non-settable identifier would break CRIU. And anything settable
will have the exact same problem. All we can do is narrowing the race
window.

For example, we could always alloc a new ifindex when moving interfaces
between name spaces. That would be probably the tiniest race window we
could get to (still not zero!) but I guess it would break apps that
assume that ifindex doesn't change when moving interfaces between name
spaces (which is not true, such apps are already broken, they just
happen to work in 99% of cases). The second best solution that doesn't
break those apps at the cost of leaving the race window wider, is this
patch.

But whatever, I don't care enough about this.

 Jiri

-- 
Jiri Benc
