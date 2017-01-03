From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH iproute2 net-next] tc: flower: support matching flags
Date: Tue, 3 Jan 2017 13:05:13 +0100
Message-ID: <20170103130513.2d7de31b@griffin>
References: <1482930409-55059-1-git-send-email-paulb@mellanox.com>
        <20170102195522.7488179b@griffin>
        <1ec4f4ca-08e0-84fc-34c6-b3868d756050@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Paul Blakey <paulb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49704 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752592AbdACMFR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 07:05:17 -0500
In-Reply-To: <1ec4f4ca-08e0-84fc-34c6-b3868d756050@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 3 Jan 2017 13:54:34 +0200, Paul Blakey wrote:
> Matching name was from the idea that we are doing is matching.

But we don't have matching_src_mac etc., either, although we're
matching on those fields.

> And regarding documentation/flag names I didn't want tc tool to be need 
> of a update each time a new flag is introduced,

It will be needed anyway because the whole thing would be useless
without proper documentation. So each time a new flag is added, a new
patch to the tc tool will be needed, at least with an addition to its
man page.

Please, let's focus on the *user*. The tc tool is hard to grasp for
users as it is. It's crystal clear to you but you know the kernel
internals. I'm very sure that except for the few kernel developers, no
one would understand what the "flags" field does. And even among the
kernel developers, very few would remember what the magic numeric
values mean.

If we want wider adoption of flower, we should make it as easy to use
as possible. Even when it means a bit more work for us.

> But I guess I can add two options like with ip_proto where you can 
> specify known flags by name but can also give a value.
> What do you think about that?
> 
> flags <FLAGS> / <HEX'/'HEX>
> FLAGS => frag/no_frag/tcp_syn/no_tcp_syn ['|'<FLAGS>]*
> e.g: flags frag|no_tcp_syn or flags 0x01/0x15
> and the mask will have a on bits corresponds only to those flags specified.

This works for me, too.

Thanks!

 Jiri
