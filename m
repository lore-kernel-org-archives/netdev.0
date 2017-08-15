From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH 03/51] ipaddress: Make buffer for filter.flushb
 static
Date: Tue, 15 Aug 2017 18:11:32 +0200
Message-ID: <20170815161132.GG16375@orbyte.nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
 <20170812120510.28750-4-phil@nwl.cc>
 <20170815081308.3feb2898@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:37261 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753032AbdHOQLd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 12:11:33 -0400
Content-Disposition: inline
In-Reply-To: <20170815081308.3feb2898@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 15, 2017 at 08:13:08AM -0700, Stephen Hemminger wrote:
> On Sat, 12 Aug 2017 14:04:22 +0200
> Phil Sutter <phil@nwl.cc> wrote:
> 
> > The buffer is accessed outside of the function defining it, so make it
> > static.
> > 
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> 
> Where does a function access this buffer which is not a sibling?

flushb is (was) an auto-variable of ipaddr_flush() which makes
filter.flushb point to it. That pointer is dereferenced from
rtnl_send_check() called by flush_update() and from print_addrinfo(). I
have to admit, the code around flushing addresses is a bit of a mystery
to me, but I don't think it's safe to access function local storage from
outside of it's scope.

Cheers, Phil
