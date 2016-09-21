From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v6 5/6] net: ipv4, ipv6: run cgroup eBPF egress programs
Date: Wed, 21 Sep 2016 20:48:27 +0200
Message-ID: <20160921184827.GA15732@pox.localdomain>
References: <1474303441-3745-1-git-send-email-daniel@zonque.org>
 <1474303441-3745-6-git-send-email-daniel@zonque.org>
 <20160919191910.GA984@salvia>
 <ac88bb4c-ab7c-1f74-c7fd-79e523b50ae4@zonque.org>
 <20160919203533.GA888@salvia>
 <83afdc54-1bbe-3530-e5fd-b74fefe9a042@zonque.org>
 <20160920142931.GA31438@salvia>
 <6584b975-fa3e-8d98-f0c7-a2c6b194b2b6@zonque.org>
 <20160921154533.GA13656@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Mack <daniel@zonque.org>, htejun@fb.com,
        daniel@iogearbox.net, ast@fb.com, davem@davemloft.net,
        kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org, sargun@sargun.me, cgroups@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37886 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964849AbcIUSsa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 14:48:30 -0400
Received: by mail-wm0-f41.google.com with SMTP id b130so107514048wmc.0
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 11:48:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160921154533.GA13656@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/21/16 at 05:45pm, Pablo Neira Ayuso wrote:
> On Tue, Sep 20, 2016 at 06:43:35PM +0200, Daniel Mack wrote:
> > The point is that from an application's perspective, restricting the
> > ability to bind a port and dropping packets that are being sent is a
> > very different thing. Applications will start to behave differently if
> > they can't bind to a port, and that's something we do not want to happen.
> 
> What is exactly the problem? Applications are not checking for return
> value from bind? They should be fixed. If you want to collect
> statistics, I see no reason why you couldn't collect them for every
> EACCESS on each bind() call.

It's not about applications not checking the return value of bind().
Unfortunately, many applications (or the respective libraries they use)
retry on connect() failure but handle bind() errors as a hard failure
and exit. Yes, it's an application or library bug but these
applications have very specific exceptions how something fails.
Sometimes even going from drop to RST will break applications.

Paranoia speaking: by returning errors where no error was returned
before, undefined behaviour occurs. In Murphy speak: things break.

This is given and we can't fix it from the kernel side. Returning at
system call level has many benefits but it's not always an option.

Adding the late hook does not prevent filtering at socket layer to
also be added. I think we need both.
