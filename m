From: Merlin Davis <me.the.wizard@gmail.com>
Subject: Re: Kernel Panic Sending Frames Using dev_queue_xmit()
Date: Wed, 25 Sep 2013 19:47:15 -0700
Message-ID: <CAFu7c2VdLARbFOBQ3MDGiSOUPgpVz6-A-66t1xXeGGnu0C8bzg@mail.gmail.com>
References: <CAFu7c2V+gubfzG4HdWtPWJ-w2x3J-RToUT2mdahcKSgn66fDzg@mail.gmail.com>
	<1380133174.2222.13.camel@bwh-desktop.uk.level5networks.com>
	<CAFu7c2XDYR-SMiuqMxtqGhfM00nw8-h0Tr2uewN8+D1BptsayA@mail.gmail.com>
	<20130925220351.GA4653@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f175.google.com ([209.85.220.175]:38286 "EHLO
	mail-vc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188Ab3IZCrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 22:47:16 -0400
Received: by mail-vc0-f175.google.com with SMTP id ia10so401420vcb.20
        for <netdev@vger.kernel.org>; Wed, 25 Sep 2013 19:47:15 -0700 (PDT)
In-Reply-To: <20130925220351.GA4653@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 25, 2013 at 3:03 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Macro expansion bug.

Yes!  Excellent.  If I change the code to:

   err = dev_queue_xmit(skb);
   err = net_xmit_eval(err);

then the panic seems to disappear (I've run for at least 30 minutes
now without a crash anyway).  Would the best fix for this in the
kernel code be to:

A.) document the net_xmit_eval() macro with a warning,
B.) add local scope the the macro with ({ ... }) to remove the double
evaluation, or
C.) do nothing in the kernel code and stop being such a dumbass when calling it?

Thank you,
Merlin
