From: "Denis V. Lunev" <den@sw.ru>
Subject: Re: [PATCH] remove __net_initdata attribute
Date: Fri, 26 Oct 2007 15:28:32 +0400
Message-ID: <4721CF60.5060600@sw.ru>
References: <20071026095652.GA8788@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, devel@openvz.org, netdev@vger.kernel.org,
	containers@lists.osdl.org, benjamin.thery@bull.net, clg@fr.ibm.com
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:53354 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750905AbXJZLZo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 07:25:44 -0400
In-Reply-To: <20071026095652.GA8788@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave, I am sorry, plz disregard the patch :(

- if the file is a part of the kernel, __exit (and pernet_unregister)
  will never called and should be dropped
- if the file is a part of a module, __init is NOT dropped on the
  module loading stage

So, we can still make embedded people happy :) Thanks Pavel to pointing
me this out.

Denis V. Lunev wrote:
> The discussion with Eric W. Biederman reveals that the concept for
> __net_initdata is bogus. The ->exit method of pernet_operations
> should be called during module exit.
> 
> So, discard this attribute.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

