From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC 0/4] xdp: use netlink extended ACK reporting
Date: Tue, 25 Apr 2017 08:53:35 -0600
Message-ID: <2fbd12c0-dfed-c8df-8c74-1686565168ab@cumulusnetworks.com>
References: <20170425080644.122536-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, johannes@sipsolutions.net,
        daniel@iogearbox.net, alexei.starovoitov@gmail.com,
        bblanco@gmail.com, john.fastabend@gmail.com, kubakici@wp.pl,
        oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:36322 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948465AbdDYOxp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 10:53:45 -0400
Received: by mail-it0-f45.google.com with SMTP id g66so20196893ite.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 07:53:44 -0700 (PDT)
In-Reply-To: <20170425080644.122536-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/25/17 2:06 AM, Jakub Kicinski wrote:

> Also - is anyone working on adding proper extack support to iproute2?
> The code I have right now is a bit of a hack...

This is what I have done:
    https://github.com/dsahern/iproute2/commits/ext-ack

Basically, added the parsing code and then a new rtnl_talk_extack
function that takes a callback to invoke with the extack data. The last
patch (of 3) purposely breaks ip set link mtu -- sending the mtu as a
u16 rather than a u32 just to work on the plumbing for parsing the
returned message:

$ ip li set dummy1 mtu 1490
Error with rtnetlink attribute IFLA_MTU

If an errmsg is returned it is printed as well.
