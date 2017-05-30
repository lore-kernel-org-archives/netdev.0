From: David Ahern <dsahern@gmail.com>
Subject: Re: loosing netdevices with namespaces and unshare?
Date: Tue, 30 May 2017 17:41:26 -0600
Message-ID: <d267709c-fd8f-bc0e-0295-29ab6422cb08@gmail.com>
References: <20170530220741.ldmhwj3bsvdoaofc@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Harald Welte <laforge@gnumonks.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:34919 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750902AbdE3Xle (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 19:41:34 -0400
Received: by mail-io0-f176.google.com with SMTP id f102so2502553ioi.2
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 16:41:34 -0700 (PDT)
In-Reply-To: <20170530220741.ldmhwj3bsvdoaofc@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/30/17 4:07 PM, Harald Welte wrote:
> In case you're wondering what I'm actually trying to achieve: Find
> an easy way to run a single program in an isolated namespace that only
> has one physical (usb) ethernet device.  I would like to execute that
> program as unprivileged user but still be able to bind to privileged
> ports.  And I want to do this using simple command-line tools without
> all the bloat and overhead of "container" solutions that have 99% of
> features I don't need.  But let that not distract you, I think the
> mysteriously disappearing netdevices are a more general and important
> issue.

An alternative approach is to create a bridge and add the usb ethernet
device to it. As you want to launch a program, create a veth pair. Put
one end into the bridge, and the other end into the new network namespace.

All of this can be scripted quite easily with 'ip' - including
configuring the veth device pushed into the namespace and running the
command. Use unshare for the other namespaces.
