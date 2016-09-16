From: Anton Aksola <aakso@iki.fi>
Subject: Re: [PATCH v2] iproute2: build nsid-name cache only for commands
 that need it
Date: Fri, 16 Sep 2016 13:18:05 +0000
Message-ID: <20160916131804.GA19216@toys.tundra.dog-lvm.novalocal>
References: <20160916072225.GA10536@toys.tundra.dog-lvm.novalocal>
 <1cced3be-a4d4-ef04-6079-e65755d9975b@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-78.nebula.fi ([83.145.220.78]:58830 "EHLO smtp.nebula.fi"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756422AbcIPNSE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Sep 2016 09:18:04 -0400
Content-Disposition: inline
In-Reply-To: <1cced3be-a4d4-ef04-6079-e65755d9975b@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 16, 2016 at 11:13:11AM +0200, Nicolas Dichtel wrote:
> There is still some differences:
> $ cat test.batch
> netns add foo
> netns set foo 1234
> netns list-id
>
> Before your patch:
> $ ip -b test.batch
> nsid 1234 (iproute2 netns name: foo)
>
> After your patch:
> $ ip -b test.batch
> nsid 1234

Nicolas,
This seems to be caused by netns_add calling unshare(CLONE_NEWNET).
If we initialize the socket for nsid after that it doesn't seem to work.

Unfortunately I'm not an expert in these details. Should we separate the
socket and cache initialization to different functions and call the
socket init in the beginning of do_netns() as before? What do you think?
I made a quick patch and it seems to work in batch mode now.

BR,
Anton
