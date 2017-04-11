From: Greg Rose <gvrose8192@gmail.com>
Subject: Re: vlan tagging problem
Date: Tue, 11 Apr 2017 13:49:38 -0700
Message-ID: <1491943778.30720.10.camel@gmail.com>
References: <CABM+yxmxfFZRtOyKbU3f1MpseQYRCReHj5uqtE3rKhaV0cUb7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: carl h <heyen2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33042 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751879AbdDKUtl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 16:49:41 -0400
Received: by mail-pf0-f172.google.com with SMTP id s16so3781197pfs.0
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 13:49:41 -0700 (PDT)
In-Reply-To: <CABM+yxmxfFZRtOyKbU3f1MpseQYRCReHj5uqtE3rKhaV0cUb7A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-11 at 15:36 -0400, carl h wrote:
> Hi
> 
> Hope this is right place to ask this. Looking for help regarding vlan
> tagging done by the 8021q driver.
> 
> I tried to manually configure a vlan on my target device. I use these
> 2 vlan config commands, then I ping an IP address and sniff the
> packets to look for the vlan tag in the messages.
> 
>    vconfig add esw0
>    ifconfig esw0.10 10.93.1.2 netmask 255.255.255.0
> 
> Despite my attempts, tagging does not occur in any outgoing packets.
> However when I tried the exact same method and commands on my Ubuntu
> workstation vlan tagging did work without problems.
> 
>     Target: mips32, Linux 2.6.39, 802.1Q driver version 1.8
> 
> I have looked at the source for the 8021q.ko driver and I keep running
> into a dead end trying to figure out where the 4 bytes of vlan data
> gets added to the IP header. There are 2 key functions where vlan
> information is deciphered and added to a structure that contains vlan
> info, but the information never gets added to the header for some
> reason.
> 
>    vlan_dev_hard_header()
>    vlan_dev_hard_start_xmit()
> 
> It is clear in the code where vlan information in receive packets gets
> removed, but not so clear in the transmit direction where this is
> supposed to happen.
> 
> Could someone explain to me what I'm missing, and where and how vlan
> info gets added to the header for outgoing packets?
> 
> thx
> /carl

The Ethernet HW probably inserts the VLAN tag for you as an 'offload'.

Run 'ethtool -k <interface>' and check the offloads.  You can change the
offload settings with 'ethtool -K..'.

- Greg Rose
