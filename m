From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: net/sched: latent livelock in dev_deactivate_many() due to
 yield() usage
Date: Wed, 5 Apr 2017 17:31:05 -0700
Message-ID: <20170405173105.7f41d7fc@plumbers-lap.home.lan>
References: <1491107321.13631.33.camel@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Peter Zijlstra <peterz@infradead.org>
To: Mike Galbraith <efault@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:37130 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752824AbdDFAbL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 20:31:11 -0400
Received: by mail-it0-f44.google.com with SMTP id a140so18275214ita.0
        for <netdev@vger.kernel.org>; Wed, 05 Apr 2017 17:31:11 -0700 (PDT)
In-Reply-To: <1491107321.13631.33.camel@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 02 Apr 2017 06:28:41 +0200
Mike Galbraith <efault@gmx.de> wrote:

> Livelock can be triggered by setting kworkers to SCHED_FIFO, then
> suspend/resume.. you come back from sleepy-land with a spinning
> kworker.  For whatever reason, I can only do that with an enterprise
> like config, my standard config refuses to play, but no matter, it's
> "Typical broken usage".
> 
> (yield() should be rendered dead)

The kernel is not normally built to have kworkers run at SCHED_FIFO.
The user has do some action to alter the process priorities.

I classify this as user error. We don't support killing kworker threads
either.
