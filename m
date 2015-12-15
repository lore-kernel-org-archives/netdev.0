From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH 0/4] ser_gigaset: fic deallocation of platform device structure
Date: Tue, 15 Dec 2015 18:11:27 +0100
Message-ID: <1450199491-30471-1-git-send-email-pebolle@tiscali.nl>
Cc: Tilman Schmidt <tilman@imap.cc>, Alan Cox <alan@linux.intel.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Peter Hurley <peter@hurleysoftware.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sascha Levin reported that the syzkaller fuzzer triggered a WARNING in
ser_gigaset (see https://lkml.kernel.org/g/56587467.8050102@oracle.com ). It
turned out that ser_gigaset has always deallocated its platform device
structure incorrectly. Tilman submitted the patch that fixes that (3/4) and a
related cleanup (4/4).

Tilman also submitted a minor cleanup of some NULL checks (1/4) that prompted
Alan to turn those checks into WARN_ONs (2/4). If no one hits these WARN_ONs in
the next couple of releases these WARN_ONs should be removed.

Alan Cox (1):
  ser_gigaset: turn nonsense checks into WARN_ON

Tilman Schmidt (3):
  ser_gigaset: fix up NULL checks
  ser_gigaset: fix deallocation of platform device structure
  ser_gigaset: remove unnecessary kfree() calls from release method

 drivers/isdn/gigaset/ser-gigaset.c | 23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

-- 
2.4.3
