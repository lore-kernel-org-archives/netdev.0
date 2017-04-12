From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: vlan tagging problem
Date: Wed, 12 Apr 2017 11:45:16 +0200
Message-ID: <20170412094516.GB13789@unicorn.suse.cz>
References: <CABM+yxmxfFZRtOyKbU3f1MpseQYRCReHj5uqtE3rKhaV0cUb7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: carl h <heyen2000@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36350 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751079AbdDLJpS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 05:45:18 -0400
Content-Disposition: inline
In-Reply-To: <CABM+yxmxfFZRtOyKbU3f1MpseQYRCReHj5uqtE3rKhaV0cUb7A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 11, 2017 at 03:36:50PM -0400, carl h wrote:
> 
> I tried to manually configure a vlan on my target device. I use these
> 2 vlan config commands, then I ping an IP address and sniff the
> packets to look for the vlan tag in the messages.
> 
>    vconfig add esw0
>    ifconfig esw0.10 10.93.1.2 netmask 255.255.255.0

I would rather suggest

  ip link add esw0.10 link esw0 type vlan id 10
  ip addr add 10.93.1.2/24 brd + dev esw0.10
  ip link set esw0.10 up

> Despite my attempts, tagging does not occur in any outgoing packets.

How do you check? If with tcpdump, on which interface?

> However when I tried the exact same method and commands on my Ubuntu
> workstation vlan tagging did work without problems.
> 
>     Target: mips32, Linux 2.6.39, 802.1Q driver version 1.8

With older versions of libpcap, tcpdump wouldn't show VLAN tags if vlan
information was passed in metadata rather than as a tag in packet itself
(which is usually the case when outgoing/incoming device supports
hardware vlan tagging/stripping). Make sure this is not your case.

Michal Kubecek
