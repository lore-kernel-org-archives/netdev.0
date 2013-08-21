From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v3 0/9] net: introduce generic type and
 helpers for IP address
Date: Tue, 20 Aug 2013 23:11:59 -0700 (PDT)
Message-ID: <20130820.231159.2092592990953992941.davem@davemloft.net>
References: <1376907278-26377-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51976 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093Ab3HUGMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 02:12:02 -0400
In-Reply-To: <1376907278-26377-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon, 19 Aug 2013 18:14:29 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> As IPv6 becomes popular, more and more subsystems begin to support IPv6,
> therefore we need a generic IP address type, in case of duplicates.
> Also we will also need some helpers to compare, print, check the generic
> IP address.
> 
> This patchset introduce a new type union inet_addr as a union of IPv4
> and IPv6 address, and struct in_addr_gen for inetpeer and bridge mdb,
> plus some helper functions that will be used by existing code and
> in the future VXLAN module.
> 
> However, due to ABI limit, we still can't convert union nf_inet_addr
> to union inet_addr.
> 
> Signed-off-by: Cong Wang <amwang@redhat.com>

I still don't want to apply this patch series, and very honestly my
patience is running very thin.

Netconsole and netpoll do not need the family field, and they
absolutely do not need the port field that a sockaddr_in et
al. provide.

So you have to get rid of it, and do the same simplification
everywhere.  So I don't have to tell you to do it again when
you resubmit this stuff and the next patch I get to has the
same exact problem.

If this patch series doesn't converge upon adding absolutely zero
overhead where it isn't needed I'm just going to auto-reject these
patches when you post them, that's how frustrated I am with this
stuff.

If in the process of commonizing you add stuff where it isn't needed
then you're doing it wrong.

That's why all these places use a different data structure!  They have
different needs.  Can you see that?
