From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH v2] iproute2: build nsid-name cache only for commands that
 need it
Date: Fri, 16 Sep 2016 17:43:05 +0200
Message-ID: <e7c6471e-66ea-aaac-40e8-6dd54792ad91@6wind.com>
References: <20160916072225.GA10536@toys.tundra.dog-lvm.novalocal>
 <1cced3be-a4d4-ef04-6079-e65755d9975b@6wind.com>
 <20160916131804.GA19216@toys.tundra.dog-lvm.novalocal>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Anton Aksola <aakso@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36939 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757736AbcIPPnJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 11:43:09 -0400
Received: by mail-wm0-f44.google.com with SMTP id k186so48823571wmd.0
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 08:43:08 -0700 (PDT)
In-Reply-To: <20160916131804.GA19216@toys.tundra.dog-lvm.novalocal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16/09/2016 à 15:18, Anton Aksola a écrit :
[snip]
> Nicolas,
> This seems to be caused by netns_add calling unshare(CLONE_NEWNET).
> If we initialize the socket for nsid after that it doesn't seem to work.
> 
> Unfortunately I'm not an expert in these details. Should we separate the
> socket and cache initialization to different functions and call the
> socket init in the beginning of do_netns() as before? What do you think?
Seems good.

> I made a quick patch and it seems to work in batch mode now.
What is the result of that sequence?

$ ip netns add bar
$ ip netns set bar 5678
$ ip -b test.batch
nsid 1234 (iproute2 netns name: foo)
nsid 5678 (iproute2 netns name: bar)
$
