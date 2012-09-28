From: Mike Harris <mharris@onxis.com>
Subject: Lab: v.1.8 + Linux 2.6.37.6+up #1 + ESXi 5.0 - VM - Slow Network Performance/Failures
Date: Fri, 28 Sep 2012 04:56:35 +0200
Message-ID: <CAJXRGag+VEMYUfhEaVwpVCUpjwC6Rhd0NeOrA15VAEz-5OwAMQ@mail.gmail.com>
References: <CAJXRGaj8t5Qx_jewDfS-zYOSQL4iNx_vLM46t72=uYF1x7x=Pw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:64815 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756110Ab2I1C4g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 22:56:36 -0400
Received: by vcbfo13 with SMTP id fo13so2847617vcb.19
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 19:56:35 -0700 (PDT)
In-Reply-To: <CAJXRGaj8t5Qx_jewDfS-zYOSQL4iNx_vLM46t72=uYF1x7x=Pw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I hope everyone is well!

Some network throughput/performance oddness with a linux based virtual =
firewall=85

Lab scenario;

[Windows VM #1] --- VLAN X-----(*)Linux Firewall VM ----- VLAN Y
---[Windows VM #2]

A tcpdump is kicked off with the following options on the firewall
this a 100MB file is copied between VM #1 to VM #2 (SMB).

tcpdump -i eth0.x -n -s0 -w file-transfer-1.pcap -c100

Notes:

+ Physical blade run ESXi 5.0.
+ Windows VMs run on the same vSwitch and physical blade.
+ VLAN X and Y support up to 1500 bytes MTU.
+ Virtual firewall is configured with the 4095 (any) VLAN (receives
and transmits tagged frames).
+ Virtual firewall is runs Linux 2.6.37.6+up #1
+ Virtual and physical backbones do support up to 9k frames.

Observations;

1. The file copy fails=85
2. The pcap reveals a 12,443 byte uber jumbo frame is present shortly
after the file transfer starts.

Repeated the same scenario using a test vyatta 6.4 VM and the file
copy completes normally=85 no jumbo frames or any other oddness.
Virtual and physical networking can not originate such a frame
normally.

Given this, I suspect there's a general framing failure of the network
driver on the virtual linux firewall, which lead me to the dmesg
command and this mailing list :)

Has anyone else seen this behavior before on a linux VM before?

Thoughts?

Helpful suggestions :)

Mike
