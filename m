From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5]: Preventing abuse when passing file descriptors
Date: Thu, 24 Apr 2014 13:45:30 -0400 (EDT)
Message-ID: <20140424.134530.1161118921944818883.davem@davemloft.net>
References: <87r44pnk3c.fsf@x220.int.ebiederm.org>
	<20140423.153216.1388028648299605195.davem@davemloft.net>
	<87a9bbeo2o.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vgoyal@redhat.com, ssorce@redhat.com, security@kernel.org,
	luto@amacapital.net, netdev@vger.kernel.org, serge@hallyn.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33053 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753900AbaDXRpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 13:45:33 -0400
In-Reply-To: <87a9bbeo2o.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 23 Apr 2014 14:24:47 -0700

> Andy Lutomirski when looking at the networking stack noticed that it is
> possible to trick privilged processes into calling write on a netlink
> socket and send netlink messages they did not intend.
> 
> In particular from time to time there are suid applications that will
> write to stdout or stderr without checking exactly what kind of file
> descriptors those are and can be tricked into acting as a limited form
> of suid cat.  In other conversations the magic string CVE-2014-0181 has
> been used to talk about this issue.
> 
> This patchset cleans things up a bit, adds some clean abstractions that
> when used prevent this kind of problem and then finally changes all of
> the handlers of netlink messages that I could find that call capable to
> use netlink_ns_capable or an appropriate wrapper.
> 
> The abstraction netlink_ns_capable verifies that the original creator of
> the netlink socket a message is sent from had the necessary capabilities
> as well as verifying that the current sender of a netlink packet has the
> necessary capabilities.
> 
> The idea is to prevent file descriptor passing of any form from
> resulting in a file descriptor that can do more than it can for the
> creator of the file descriptor.

Series applied, thanks Eric.
