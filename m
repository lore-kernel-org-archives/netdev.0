From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v4 09/13] net: ethernet: ti: cpts: rework
 initialization/deinitialization
Date: Tue, 6 Dec 2016 19:04:21 +0100
Message-ID: <20161206180421.GA20480@localhost.localdomain>
References: <20161205200525.16664-1-grygorii.strashko@ti.com>
 <20161205200525.16664-10-grygorii.strashko@ti.com>
 <20161206134037.GA15946@localhost.localdomain>
 <4e7888b6-9f1c-ca31-e83e-15109bf1df3f@ti.com>
 <20161206171802.GA19646@localhost.localdomain>
 <c0d6d670-cf44-c113-3443-3b5209e68ee2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, devicetree@vger.kernel.org,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Thomas Gleixner <tglx@linutronix.de>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36565 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751581AbcLFSE1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 13:04:27 -0500
Content-Disposition: inline
In-Reply-To: <c0d6d670-cf44-c113-3443-3b5209e68ee2@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 06, 2016 at 11:49:14AM -0600, Grygorii Strashko wrote:
> But we do reset whole cpsw :( and that's required to support PM use cases as
> suspend/resume.

The code is resetting the clock unconditionally on ifup/down.  That
sucks.  If you reset the clock *only* after resume, that would be ok.
 
> There are also PM requirement to shutdown cpsw in case all interfaces are down.

Well, those requirements are not too smart.  As an end user, I expect
that ifdown/up does not change the time.  There isn't any reason to
reset the clock in this case.

> More over, there are requirement to minimize cpsw power consumption in case all links are
> disconnected (and cpts is special case here).
> 
> So, at least resetting of the timecounter still required.

Only if you follow that poorly conceived PM plan.  Anyhow, I agree
that it isn't the task of your present series to fix that.

> Ok. I'll try to optimize it following your directions.

What I would like to see is: initialize the cyclecounter fields
exactly once.

Thanks,
Richard
