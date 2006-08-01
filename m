From: Phil Oester <kernel@linuxace.com>
Subject: Re: [patch] RFC: matching interface groups
Date: Tue, 1 Aug 2006 11:46:55 -0700
Message-ID: <20060801184655.GA7452@linuxace.com>
References: <1154452209.6395.77.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-67-120-171-161.dsl.lsan03.pacbell.net ([67.120.171.161]:63755
	"HELO linuxace.com") by vger.kernel.org with SMTP id S1751784AbWHASqz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 14:46:55 -0400
To: Balazs Scheidler <bazsi@balabit.hu>
Content-Disposition: inline
In-Reply-To: <1154452209.6395.77.camel@bzorp.balabit>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2006 at 07:10:09PM +0200, Balazs Scheidler wrote:
> Each interface can belong to a single "group" at a time, an interface
> comes up without being a member in any of the groups.
> 
> Userspace can assign interfaces to groups after being created, this
> would typically be performed in /etc/ppp/ip-up.d (and similar) scripts.

Since in this scenario userspace is able to determine ppp vs pptp, 
could you not also do something like have an inbound_ppp and inbound_pptp
chain, then jump to the appropriate chain depending on type?  If you
need per-interface rules, then create an inbound_pppX chain, populate
it with rules, then jump to that chain if -i pppX.  In ip-down, just
delete the chain as well as the jump.

Phil
