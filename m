From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH 50/51] Check user supplied interface name lengths
Date: Tue, 15 Aug 2017 18:51:32 +0200
Message-ID: <20170815165132.GI16375@orbyte.nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
 <20170812120510.28750-51-phil@nwl.cc>
 <20170815090945.62b2c4d7@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:50375 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752617AbdHOQvd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 12:51:33 -0400
Content-Disposition: inline
In-Reply-To: <20170815090945.62b2c4d7@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 15, 2017 at 09:09:45AM -0700, Stephen Hemminger wrote:
> On Sat, 12 Aug 2017 14:05:09 +0200
> Phil Sutter <phil@nwl.cc> wrote:
> 
> > +void assert_valid_dev_name(const char *, const char *);
> 
> Not a fan of long function names.
> “I have only made this letter longer because I have not had the time to make it shorter."

:)

> Maybe just add a new function addattr_ifname() and add the checking there?

It is not only about netlink attributes - these are in fact
unproblematic, since they allow for interface names longer than
IFNAMSIZ-1 and the kernel will then reject. The length check has to
happen before copying into any IFNAMSIZ-sized buffer takes place (e.g.
ifr_name of struct ifreq). Logically I would prefer to perform the
checks right at the point user input parsing takes place since it
belongs there.

I could rename the function to 'ifname_valid' instead? I liked having
'assert' in the name though, since the function calls exit() on error.

Thanks, Phil
