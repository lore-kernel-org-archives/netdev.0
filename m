From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: [PATCH v3 0/7] pppoatm: fix multiple issues with pppoatm driver
Date: Tue,  6 Nov 2012 23:16:55 +0100
Message-ID: <1352240222-363-1-git-send-email-krzysiek@podlesie.net>
Cc: linux-kernel@vger.kernel.org,
	Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	David Woodhouse <David.Woodhouse@intel.com>,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patch series fixes multiple issues in the pppoatm driver.
Two of them can be easily triggered and appropriate Oops messages
were added.

Changes in v3:

- the original crash after closing vcc is now fixed in ATM layer
  by "[PATCH v3 1/7] atm: detach protocol before closing vcc",
  this also fixes the same issue with other ATM protocols,
  suggested by Chas Williams

- add "[PATCH v3 2/7] atm: add owner of push() callback to atmvcc"
  and "[PATCH v3 4/7] pppoatm: fix module_put() race" to remove
  assumption of Big Kernel Lock, which is no longer true.
  The same assumption exists also in other ATM protocols, but it's
  not fixed by this version.

- patch "[PATCH v3 3/7] pppoatm: allow assign only on a connected socket"
  was added to fix crash, when pppoatm was used on non fully-connected
  socket.

- the order of patches 1 and 2 from v2, now
  "[PATCH v3 5/7] pppoatm: take ATM socket lock in pppoatm_send()"
  and "[PATCH v3 6/7] pppoatm: don't send frames on not-ready vcc"
  was reversed, in "[PATCH v3 5/7] pppoatm: take ATM socket lock
  in pppoatm_send()" lock operation was moved earlier to protect
  also pppoatm_may_send(), as suggested by David Woodhouse

  Both patches were previously Acked by David Woodhouse,
  but now they are slightly modified and commit message is
  rewritten, because orignal issue is already fixed in
  "PATCH v3 1/7".

- the "[PATCH v2 3/3] pppoatm: protect against freeing of vcc"
  was dropped because it's not necessary, this protection
  is already provided by ATM layer


[v2]

"[PATCH v2 1/3] pppoatm: don't send frames to destroyed vcc"
http://marc.info/?l=linux-kernel&m=135092672625585&w=2

[v1]	"[PATCH] pppoatm: don't send frames to destroyed vcc"

Krzysztof Mazur
