From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next RFC v2 0/3] light weight tunnel infrastructure and driver
Date: Thu, 18 Jun 2015 21:49:12 -0700
Message-ID: <1434689355-4088-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: ebiederm@xmission.com, rshearma@brocade.com, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:34114 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751418AbbFSEtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 00:49:20 -0400
Received: by pdbki1 with SMTP id ki1so82140756pdb.1
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2015 21:49:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This series implements infrastructure for light weight tunnels to support
mpls label edge routers (ie mpls ip tunnels). As previously discussed 
having netdevices will not scale. Hence this series introduces new RTA_ENCAP*
attributes to attach encap information with routes (following suggestion
from Eric Biederman).

The first patch introduces an infrastructure to support light weight tunnels
that dont have netdevices. The infrastructure allows tunnel drivers
to register handlers to parse and build tunnel encap data which can be attached
to each route nexthop.

The second patch adds support in ipv4 fib to carry such light weight tunnel
encap data.

The third patch implements mpls ip tunnels using this light weight tunnel
infrastructure.

Could not think of a better name, so, it is 'lwt' for 'light weight tunnels'
for now.

I do have iproute2 patches. Can post them separately if required
(they are currently in my github tree
https://github.com/CumulusNetworks/iproute2 (mpls branch))

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
----
v2:
	- bug fixes (more testing)
	- feedback from Thomas
		- A flag in lwtunnel state that allows using the chosen
		  output device instead of redirecting dst output to the
		  lwt output function.
		- This flag can be set by the tunnel driver at tunnel state
		  build time
	- moved lwtstate pointer from dst_entry to rtable (seemed cleaner
	looking at thomas's openvswitch patches)
	- moved mpls iptunnel code into separate file (following erics and
	roberts initial patches)

Roopa Prabhu (3):
  lwt: infrastructure to support light weight tunnels
  ipv4: add support for light weight tunnel encap attributes
  mpls: support for ip mpls tunnels

 include/linux/lwtunnel.h           |    6 ++
 include/linux/mpls_iptunnel.h      |    6 ++
 include/net/ip_fib.h               |    7 +-
 include/net/lwtunnel.h             |   84 +++++++++++++++
 include/net/mpls_iptunnel.h        |   29 +++++
 include/net/route.h                |    3 +
 include/uapi/linux/lwtunnel.h      |   11 ++
 include/uapi/linux/mpls_iptunnel.h |   26 +++++
 include/uapi/linux/rtnetlink.h     |    3 +-
 net/Kconfig                        |    5 +
 net/core/Makefile                  |    1 +
 net/core/lwtunnel.c                |  162 ++++++++++++++++++++++++++++
 net/ipv4/fib_frontend.c            |    8 ++
 net/ipv4/fib_semantics.c           |   93 +++++++++++++++-
 net/ipv4/route.c                   |   33 +++++-
 net/mpls/Kconfig                   |    5 +
 net/mpls/Makefile                  |    1 +
 net/mpls/af_mpls.c                 |    9 +-
 net/mpls/internal.h                |    3 +
 net/mpls/mpls_iptunnel.c           |  205 ++++++++++++++++++++++++++++++++++++
 20 files changed, 692 insertions(+), 8 deletions(-)
 create mode 100644 include/linux/lwtunnel.h
 create mode 100644 include/linux/mpls_iptunnel.h
 create mode 100644 include/net/lwtunnel.h
 create mode 100644 include/net/mpls_iptunnel.h
 create mode 100644 include/uapi/linux/lwtunnel.h
 create mode 100644 include/uapi/linux/mpls_iptunnel.h
 create mode 100644 net/core/lwtunnel.c
 create mode 100644 net/mpls/mpls_iptunnel.c

-- 
1.7.10.4
