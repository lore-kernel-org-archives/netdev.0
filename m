From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net 0/2] lwtunnel: make it really work, for IPv4
Date: Wed, 23 Sep 2015 16:29:27 +0200
Message-ID: <20150923162927.6d437a1f@griffin>
References: <cover.1442936392.git.jbenc@redhat.com>
	<87zj0d92ba.fsf@x220.int.ebiederm.org>
	<20150923080957.GB29680@pox.localdomain>
	<87lhbx72j2.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57850 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754633AbbIWO3c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2015 10:29:32 -0400
In-Reply-To: <87lhbx72j2.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Sep 2015 07:17:53 -0500, Eric W. Biederman wrote:
> Assuming the transport is UDP then it would be a UDP socket.  That
> socket will have all of the information needed to construct the outer
> header as the receive path of that socket removes the outer header.
> 
> I admit you can't use the cached dst.  It is the wrong on that socket.
> 
> My point is that if we have the UDP socket and we have the sk we have
> all of the information we need to compute the reverse dst.

That (single) UDP socket may represent many tunnels with different
parameters. Knowing the socket is still not enough to construct the
data. The only place where the needed data is stored is routing table
which won't help us much for ARP, and the metadata dst attached to the
incoming skb.

 Jiri

-- 
Jiri Benc
