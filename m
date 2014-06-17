From: Cong Wang <cwang@twopensource.com>
Subject: Re: Fw: [Bug 78161] New: Missing NULL check of the return value of
 nla_nest_start() in function sfb_dump()
Date: Tue, 17 Jun 2014 14:31:36 -0700
Message-ID: <CAHA+R7NY2g+tEeBXYPWaDRgrqq23Zo7uwV8PVFHAu0frprYYZw@mail.gmail.com>
References: <20140617135211.2a768f1b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:55982 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965077AbaFQVbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 17:31:37 -0400
Received: by mail-qa0-f53.google.com with SMTP id j15so9703373qaq.40
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2014 14:31:36 -0700 (PDT)
In-Reply-To: <20140617135211.2a768f1b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2014 at 1:52 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> Function nla_nest_start() may return a NULL pointer, and its return value shall
> be checked before used. But in function sfb_dump() after nla_nest_start() is
> called(at net/sched/sch_sfb.c:559), the return value is immediately used as a
> parameter of nla_nest_end() without NULL check. Besides, there is no check
> before the parameter is dereferenced in the callee function nla_nest_end(). So
> an invalid memory access may be triggered.
> The related code snippets in sfb_dump() are as following.
> sfb_dump() @@net/sched/sch_sfb.c:559
> 559         opts = nla_nest_start(skb, TCA_OPTIONS);
> 560         NLA_PUT(skb, TCA_SFB_PARMS, sizeof(opt), &opt);
> 561         return nla_nest_end(skb, opts);

This was fixed by:

commit 7ac2908e4b2edaec60e9090ddb4d9ceb76c05e7d
Author: Alan Cox <alan@linux.intel.com>
Date:   Thu Jul 12 03:39:11 2012 +0000

    sch_sfb: Fix missing NULL check
