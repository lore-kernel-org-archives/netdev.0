From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] lwtunnel: fix autoload of lwt modules
Date: Tue, 17 Jan 2017 15:38:46 -0500 (EST)
Message-ID: <20170117.153846.1832359427601278475.davem@davemloft.net>
References: <8b621810-f7b3-05bb-413b-29389125c6ea@cumulusnetworks.com>
        <0e226af4-cb62-9b20-f8a2-191b0aaffb11@brocade.com>
        <54cf1176-5131-c0a0-572e-47feda7e07a9@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rshearma@brocade.com, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43406 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750947AbdAQUj4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 15:39:56 -0500
In-Reply-To: <54cf1176-5131-c0a0-572e-47feda7e07a9@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 17 Jan 2017 11:04:35 -0700

> handling restart for all code paths seems a bit risky for
> 4.10. Perhaps then the best course for 4.10 and older stable
> releases is to remove the autoload code from lwtunnel. It can be
> re-added once the recovery path is handled.

Indeed, we would need to handle the restart rather far up in the call chain
above where the newroute message gets processed.

But, that being said, I don't think we can legitimately just remove the
autoload functionality.  It's been there for close to a full year and
I guarantee people will get burned if we take it away.

We have to find a way to fix this.
