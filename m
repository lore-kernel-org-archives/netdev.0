From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Suspicious RCU usage in bridge with Linux
 v4.0-9362-g1fc149933fd4
Date: Mon, 4 May 2015 13:27:14 -0700
Message-ID: <20150504132714.55dca5b0@urahara>
References: <CA+5PVA5gE_pG5iPKBgugsEjLsOYvq9bWKfB+2OeEujjdOb+URg@mail.gmail.com>
	<20150504133943.GA17043@x131e>
	<CAHA+R7PAzzz+CZfnOoweBdeLY8tRkr2bSDEpQgdtEKUeaZbWpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dominick Grift <dac.override@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:36256 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513AbbEDU1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 16:27:11 -0400
Received: by pdea3 with SMTP id a3so172951819pde.3
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 13:27:10 -0700 (PDT)
In-Reply-To: <CAHA+R7PAzzz+CZfnOoweBdeLY8tRkr2bSDEpQgdtEKUeaZbWpQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 4 May 2015 11:45:41 -0700
Cong Wang <cwang@twopensource.com> wrote:

> On Mon, May 4, 2015 at 6:39 AM, Dominick Grift <dac.override@gmail.com> wrote:
> > On Thu, Apr 23, 2015 at 01:07:45PM -0400, Josh Boyer wrote:
> >> Hi All,
> >>
> >> We've had a user report the following backtrace from the bridge module
> >> with a recent Linus' tree.  Has anything like this been reported yet?
> >> If you have any questions on setup, the user is CC'd.
> >>
> >> josh
> >>
> >> [   29.382235] br0: port 1(tap0) entered forwarding state
> >>
> >> [   29.382286] ===============================
> >> [   29.382315] [ INFO: suspicious RCU usage. ]
> >> [   29.382344] 4.1.0-0.rc0.git11.1.fc23.x86_64 #1 Not tainted
> >> [   29.382380] -------------------------------
> >> [   29.382409] net/bridge/br_private.h:626 suspicious
> >> rcu_dereference_check() usage!
> >
> > <snip>
> >
> > With 4.1.0-0.rc1.git1.1.fc23.x86_64 the situation seems to have slightly changed:
> >
> 
> Should be the same issue. Please give the attached patch a try,
> it is compile-tested only.
> 
> Thanks!

Good analysis in identifying the issue. But the proposed patch
doesn't seem right.

The br->lock protects against changes to the bridge port state.
vlan_info should be treated as part of the bridge state.

The correct fix is to get vlan_info out of depending on RTNL
and use br->lock to control modifications.
