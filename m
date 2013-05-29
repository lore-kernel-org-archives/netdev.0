From: Joao Correia <joaomiguelcorreia@gmail.com>
Subject: Re: Network issue on 3.10 rcs, bisected
Date: Wed, 29 May 2013 20:53:16 +0100
Message-ID: <CACG0VPWeu8JoMYJNnQ39zvubftpeTB_EvKNrxZm7Op9q6HUVXA@mail.gmail.com>
References: <CACG0VPV3-x5Ncp+_hci8wVNYUeqAUZ0KFm0MAuHMntXzaL9Nqw@mail.gmail.com>
 <CALnjE+p3vFkYBu=XioeDTEL1cyXh_379ix84Yoojj1eB11q57Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: LKML <linux-kernel@vger.kernel.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:48053 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758817Ab3E2Tx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 15:53:58 -0400
In-Reply-To: <CALnjE+p3vFkYBu=XioeDTEL1cyXh_379ix84Yoojj1eB11q57Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 29, 2013 at 7:59 PM, Pravin Shelar <pshelar@nicira.com> wrote:
>
> On Wed, May 29, 2013 at 4:37 AM, Joao Correia
> <joaomiguelcorreia@gmail.com> wrote:
> > Hello list
> >
> > While trying the rc's for 3.10, i've stumbled upon a problem where
> > networking does not work at all. Iptables will show packet counts going up,
> > but nothing actually reaches the programs.
> >
> > I'm running fedora under hyper-v 3 (a windows 2012 host). Only tested ipv4
> > traffic, and everything times out (ping, telnet to open ports) on both
> > directions. The networking devices come up apparently ok - has static ip
> > set, and dmesg shows no errors (although i don't have many debugging options
> > enabled).
> >
> > I bisected this, and git blames commit
> > ec5f061564238892005257c83565a0b58ec79295 (net: ill link between CSUM and SG
> > features.). I can't revert it cleanly on current rc's.
> >
> Can you also send network features set on the device?
> ethtool -k <dev>


As requested:
Features for eth0:
rx-checksumming: off [fixed]
tx-checksumming: off
    tx-checksum-ipv4: off [fixed]
    tx-checksum-ip-generic: off [fixed]
    tx-checksum-ipv6: off [fixed]
    tx-checksum-fcoe-crc: off [fixed]
    tx-checksum-sctp: off [fixed]
scatter-gather: on
    tx-scatter-gather: on
    tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: off
    tx-tcp-segmentation: off [fixed]
    tx-tcp-ecn-segmentation: off [fixed]
    tx-tcp6-segmentation: off [fixed]
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: off
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: off [fixed]
tx-vlan-ctag-hw-insert: on [fixed]
rx-vlan-ctag-hw-parse: off [fixed]
rx-vlan-ctag-filter: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]

The output is similar on a working (3.9) and a bad (3.10) kernel.
diff-ing both outputs shows:
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
as last on the broken kernels.

Thank you for your time,
Joao Correia
CIUBI
Universidade da Beira Interior
Portugal
