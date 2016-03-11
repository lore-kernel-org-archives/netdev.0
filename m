From: David Decotigny <ddecotig@gmail.com>
Subject: [ethtool PATCH v4 00/11] add support for new ETHTOOL_xLINKSETTINGS ioctls
Date: Fri, 11 Mar 2016 09:58:13 -0800
Message-ID: <1457719104-39188-1-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34444 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbcCKR6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 12:58:32 -0500
Received: by mail-pa0-f66.google.com with SMTP id hj7so9037303pac.1
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 09:58:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Decotigny <decot@googlers.com>

This adds support for the new ETHTOOL_xLINKSETTINGS ioctls. This also
fixes a few compilation warnings as well as a heap corruption bug.

History:
  v4
    review Ben Hutchings:
      using AF_UNIX instead of INET6 in the absence of v4 sockets
      use stdbool.h
      do_seeprom always fails when offset/length out of bounds
      sync to latest ethtool.h + kernel.h from net-next
      __SANE_USERSPACE_TYPES__ always defined
      cosmetic updates for var =3D=3D const tests
      cosmetic updates for associativity in tests
  v3
    TRUE/FALSE obvious-ification
  v2
    added do_seeprom patch
    added netdev@ as recipient
  v1
    initial submission

############################################
# Patch Set Summary:

David Decotigny (7):
  ethtool.c: don't ignore fread() return value
  ethtool.c: fix dump_regs heap corruption
  ethtool.c: do_seeprom checks for params & stdin sanity
  kernel-copy.h: import kernel.h from net-next and use it
  ethtool-copy.h: sync with net-next
  ethtool.c: add support for ETHTOOL_xLINKSETTINGS ioctls
  ethtool.c: support absence of v4 sockets

Maciej =C5=BBenczykowski (4):
  internal.h: change to new sane kernel headers on 64-bit archs
  marvell.c: fix strict alias warnings
  test-common.c: fix test_realloc(NULL, ...)
  test-features.c: add braces around array initialization

 ethtool-copy.h  | 478 ++++++++++++++++++++++++++++++------
 ethtool.c       | 751 ++++++++++++++++++++++++++++++++++++++++++------=
--------
 internal.h      |  77 +++++-
 kernel-copy.h   |  14 ++
 marvell.c       |  21 +-
 test-cmdline.c  |  12 +
 test-common.c   |   2 +-
 test-features.c |   2 +-
 8 files changed, 1086 insertions(+), 271 deletions(-)
 create mode 100644 kernel-copy.h

--=20
2.7.0.rc3.207.g0ac5344
