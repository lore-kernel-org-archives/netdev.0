From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] netns: avoid directory traversal (was: ip netns: Make
 sure netns name is sane)
Date: Tue, 18 Jul 2017 17:12:30 -0700
Message-ID: <20170718171230.084c804e@xeon-e3>
References: <20170710120831.9355-1-mcroce@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Matteo Croce <mcroce@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:34917 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751962AbdGSANX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 20:13:23 -0400
Received: by mail-pg0-f53.google.com with SMTP id v190so21091117pgv.2
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 17:13:22 -0700 (PDT)
In-Reply-To: <20170710120831.9355-1-mcroce@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Jul 2017 14:08:31 +0200
Matteo Croce <mcroce@redhat.com> wrote:

> Hi Phil,
> 
> I noticed that your patch still leaves an uncovered scenario, the one where the
> namespace name is "." or "..".
> Calling 'ip netns del ..' will remove /var/run which is a symlink to /run on
> most systems causing some daemons, eg. dbus, to fail.
> 
> ip netns doesn't validate input, allowing creation and deletion of files
> relatives to /var/run/netns.
> This patch denies creation or deletion of namespaces with names contaning
> "/" or that matches exactly "." or "..".
> ---
>  ip/ipnetns.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 

The patch itself is good, but the commit message needs fixing.
Please rewrite it to describe the problem, and add signed-off-by
