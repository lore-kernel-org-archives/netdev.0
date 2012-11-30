From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 00/17] ATM fixes for pppoatm/br2684
Date: Fri, 30 Nov 2012 00:35:19 +0000
Message-ID: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Cc: chas@cmf.nrl.navy.mil, krzysiek@podlesie.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:47034
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754856Ab2K3Agf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 19:36:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the result of pulling on the thread started by Krzysztof Mazur's
original patch 'pppoatm: don't send frames to destroyed vcc'.

Various problems in the pppoatm and br2684 code are solved, some of which
were easily triggered and would panic the kernel.

The patch series can be pulled from
	git://git.infradead.org/users/dwmw2/atm.git
or viewed at 
	http://git.infradead.org/users/dwmw2/atm.git

DaveM, please wait for an ack from Krzysztof and Chas before pulling this.

David Woodhouse (9):
      solos-pci: Wait for pending TX to complete when releasing vcc
      br2684: don't send frames on not-ready vcc
      atm: Add release_cb() callback to vcc
      pppoatm: fix missing wakeup in pppoatm_send()
      br2684: fix module_put() race
      pppoatm: optimise PPP channel wakeups after sock_owned_by_user()
      solos-pci: clean up pclose() function
      solos-pci: use GFP_KERNEL where possible, not GFP_ATOMIC
      solos-pci: remove list_vccs() debugging function

Krzysztof Mazur (7):
      atm: add owner of push() callback to atmvcc
      pppoatm: allow assign only on a connected socket
      pppoatm: fix module_put() race
      pppoatm: take ATM socket lock in pppoatm_send()
      pppoatm: drop frames to not-ready vcc
      pppoatm: do not inline pppoatm_may_send()
      br2684: allow assign only on a connected socket

Nathan Williams (1):
      solos-pci: Fix leak of skb received for unknown vcc
