From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: [PATCHv4 net-next 0/8] Phonet: pipe protocol cleanup
Date: Wed, 9 Mar 2011 10:43:32 +0200
Message-ID: <201103091043.32391.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.1.48]:32226 "EHLO mgw-sa02.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756650Ab1CIInd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 03:43:33 -0500
Received: from leon.remlab.net (esdhcp034153.research.nokia.com [172.21.34.153])
	by mgw-sa02.nokia.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id p298hVN4032478
	for <netdev@vger.kernel.org>; Wed, 9 Mar 2011 10:43:32 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Hello,

As "promised", here is the cleaned up and unified Phonet pipe code.
The same kernel can now support both old (e.g. Nokia N900) and new
(e.g. ST-Ericsson U8500 SoC) modems.

The following changes since commit 7b46ac4e77f3224a1befe032c77f1df31d1b=
42c4:

  inetpeer: Don't disable BH for initial fast RCU lookup. (2011-03-08 1=
4:59:28 -0800)

are available in the git repository at:
  git://git.remlab.net/linux-phonet.git master

R=C3=A9mi Denis-Courmont (8):
      Phonet: fix NULL dereference on TX path with implicit source
      Phonet: return an error when packet TX fails
      Phonet: correct pipe backlog callback return values
      Phonet: factor common code to send control messages
      Phonet: allocate sock from accept syscall rather than soft IRQ
      Phonet: provide pipe socket option to retrieve the pipe identifie=
r
      Phonet: support active connection without pipe controller on mode=
m
      Phonet: kill the ST-Ericsson pipe controller Kconfig

 Documentation/networking/phonet.txt |   67 ++---
 include/linux/phonet.h              |    4 +-
 include/net/phonet/pep.h            |    1 -
 net/phonet/Kconfig                  |   12 -
 net/phonet/af_phonet.c              |   13 +-
 net/phonet/pep.c                    |  682 ++++++++++++++-------------=
--------
 net/phonet/socket.c                 |  112 +++----
 7 files changed, 352 insertions(+), 539 deletions(-)

--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.net/
