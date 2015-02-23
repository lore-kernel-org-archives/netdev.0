From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 0/9] be2net: patch set
Date: Mon, 23 Feb 2015 04:20:07 -0500
Message-ID: <1424683216-29611-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:32982 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751413AbbBWJRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 04:17:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, the following patch set reduces code duplication
in probe/pci-resume/eeh-resume and remove/pci-suspend/eeh-error and UE-error
detect/recovery paths. New helper routines have been introduced for this
purpose. Pls apply this set to the net-next tree. Thanks!

Patch 1 refactors the alloc/free code of adapter struct's fields into
a new set of helper routines -- be_drv_init/cleanup().

Patch 2 gets rid of the be_get_initial_config() routine as be_get_config()
is the place holder for related code.

Patch 3 introduces a new helper routine be_func_init() to execute the
initialization code used in probe/pci-resume/eeh-resume to remove
code duplication.

Patch 4 introduces a wrapper for scheduling/canceling error detection
task on similar lines to the be_worker task.

Patch 5 refactors UE error detection and recovery code on similar lines
to EEH code. Cleaning up resources is done in the error detection routine
followed by error recovery.

Patch 6 gets rid of the lancer_test_and_set_rdy_state() routine as the
same code now available in be_func_init().

Patch 7 creates a new helper routine be_resume() for all the common code
in be_probe(), be_pci_resume() and be_eeh_resume(), to reduce code duplication.

Patch 8 creates a new helper routine be_cleanup() for all the common
cleanup code duplicated in the suspend/EEH err detection paths.

Patch 9 moves be_func_init() inside be_setup() as everytime be_setup()
is called, the driver will have to wait for the function/FW to be be
initialized.

Kalesh AP (3):
  be2net: refactor error detect/recovery function
  be2net: refactor adapter resource initialzation sequence into
    be_resume()
  be2net: refactor adapter resource cleanup sequence into be_cleanup()

Sathya Perla (6):
  be2net: move adapter fields alloc/free code to new routines
  be2net: get rid of be_get_initial_config() call from be_probe()
  be2net: refactor function initalization sequence into be_func_init()
  be2net: use a wrapper to schedule and cancel error detection task
  be2net: remove code duplication relating to Lancer reset sequence
  be2net: move be_func_init() call inside be_setup()

 drivers/net/ethernet/emulex/benet/be.h      |   3 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c |  85 +---
 drivers/net/ethernet/emulex/benet/be_main.c | 625 +++++++++++++---------------
 3 files changed, 303 insertions(+), 410 deletions(-)

-- 
2.2.0
