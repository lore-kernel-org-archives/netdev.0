From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Subject: [RFC PATCH  ethtool 0/2] ethtool: Add support for FEC encoding configuration
Date: Tue, 25 Oct 2016 14:39:20 -0700
Message-ID: <1477431562-38455-1-git-send-email-vidya@cumulusnetworks.com>
Cc: roees@mellanox.com, dustin@cumulusnetworks.com,
        roopa@cumulusnetworks.com, aviadr@mellanox.com
To: davem@davemloft.net, netdev@vger.kernel.org,
        linville@tuxdriver.com, saeedm@mellanox.com, galp@mellanox.com,
        odedw@mellanox.com, ariela@mellanox.com, tzahio@mellanox.com,
        ddecotig@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35717 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941957AbcJYVj3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 17:39:29 -0400
Received: by mail-pf0-f175.google.com with SMTP id s8so125881343pfj.2
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 14:39:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>

Forward Error Correction (FEC) modes i.e Base-R
and Reed-Solomon modes are introduced in 25G/40G/100G standards
for providing good BER at high speeds.
Various networking devices which support 25G/40G/100G provides ability
to manage supported FEC modes and the lack of FEC encoding control and
reporting today is a source for itneroperability issues for many vendors.
FEC capability as well as specific FEC mode i.e. Base-R
or RS modes can be requested or advertised through bits D44:47 of base link
codeword.

This patch set intends to provide option under ethtool to manage and report
FEC encoding settings for networking devices as per IEEE 802.3 bj, bm and by
specs.

set-fec/show-fec option(s) are  designed to provide  control and report
the FEC encoding on the link.

SET FEC option:
root@tor: ethtool --set-fec  swp1 encoding [off | RS | BaseR | auto] autoneg [off | on]

Encoding: Types of encoding
Off    :  Turning off any encoding
RS     :  enforcing RS-FEC encoding on supported speeds
BaseR  :  enforcing Base R encoding on supported speeds
Auto   :  Default FEC settings  for  divers , and would represent
          asking the hardware to essentially go into a best effort mode.

Here are a few examples of what we would expect if encoding=auto:
- if autoneg is on, we are  expecting FEC to be negotiated as on or off
  as long as protocol supports it
- if the hardware is capable of detecting the FEC encoding on it's
      receiver it will reconfigure its encoder to match
- in absence of the above, the configuration would be set to IEEE
  defaults.

>From our  understanding , this is essentially what most hardware/driver
combinations are doing today in the absence of a way for users to
control the behavior.

SHOW FEC option:
root@tor: ethtool --show-fec  swp1
FEC parameters for swp1:
Autonegotiate:  off
FEC encodings:  RS

ETHTOOL DEVNAME output modification:

ethtool devname output:
root@tor:~# ethtool swp1
Settings for swp1:
root@hpe-7712-03:~# ethtool swp18
Settings for swp18:
    Supported ports: [ FIBRE ]
    Supported link modes:   40000baseCR4/Full
                            40000baseSR4/Full
                            40000baseLR4/Full
                            100000baseSR4/Full
                            100000baseCR4/Full
                            100000baseLR4_ER4/Full
    Supported pause frame use: No
    Supports auto-negotiation: Yes
    Supported FEC modes: [RS | BaseR | None | Not reported]
    Advertised link modes:  Not reported
    Advertised pause frame use: No
    Advertised auto-negotiation: No
    Advertised FEC modes: [RS | BaseR | None | Not reported]
<<<< One or more FEC modes
    Speed: 100000Mb/s
    Duplex: Full
    Port: FIBRE
    PHYAD: 106
    Transceiver: internal
    Auto-negotiation: off
    Link detected: yes

Vidya Sagar Ravipati (2):
  ethtool-copy.h: sync with net
  ethtool: Support for FEC encoding control

 ethtool-copy.h |  53 +++++++++++++++++++-
 ethtool.c      | 152 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 203 insertions(+), 2 deletions(-)

-- 
2.1.4
