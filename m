From: Robert LeBlanc <robert@leblancnet.us>
Subject: mlx5en not able to communicate between VF and PF
Date: Thu, 20 Apr 2017 14:06:32 -0600
Message-ID: <CAANLjFqWJVs=DsONedX0-TpGCDUQUuj6v3va2MXZaStoATFtzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:35561 "EHLO
        mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947376AbdDTUGd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 16:06:33 -0400
Received: by mail-oi0-f48.google.com with SMTP id j201so65987996oih.2
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 13:06:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After figuring out that CentOS requires a newer version of iproute to
enable trust mode on VFs, I'm now having a problem getting a VM on a
bridge on a VF to communicate with the host on the PF or a different
VF.

The set-up:

             Host1                                    Host2

 /--------------------------------------------\
 |                                            |
PF - 192.168.13.13/24                        PF - 192.168.13.14/24
 +-- VF1 - (Move the address
 |          from PF for testing)
 \-- VF2 - br0
            +-- VM1 - 192.168.13.101/24
            +-- VM2 - 192.168.13.102/24
            \-- VM3 - 192.168.13.103/24

Host1 and Host2 have a Mellanox ConnectX-4 100Gb single port adapter
and are connected back-to-back with no switch between them. Host1 VF2
has trust mode set to on. From Host2, I can ping any address on Host1
(PF, VM1, VM2, VM3). From VM3, I can ping VM1, VM2 and Host2 PF. From
Host1 PF, I can ping Host2 PF.

The problem is that none of the VMs can ping Host1 PF nor can the
Host1 PF ping any of the VMs.

While doing tcpdump on the interfaces and a ping from VM3, I can see
the ARP request go through VF2, I can see the request and the response
on PF, but the response never makes it back to VF2.

When I ping from Host1 PF to VM3, I see the ARP request and response
on both the PF and VF2, however the ICMP request is sent on the PF,
but the VF2 never sees it.

If I move the Host1 PF address to a VF, the same problem happens.

It seems to me that some rule in the eswitch is getting in the way,
but I don't know how to view/modify the rules in the eswitch.

Any help getting this working is appreciated.

Thank you,
----------------
Robert LeBlanc
PGP Fingerprint 79A2 9CA4 6CC4 45DD A904  C70E E654 3BB2 FA62 B9F1
