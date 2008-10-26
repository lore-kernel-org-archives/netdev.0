From: Arjan van de Ven <arjan@infradead.org>
Subject: bisected: 2.6.28-rc broke my iwl4965 wireless
Date: Sat, 25 Oct 2008 22:22:08 -0700
Message-ID: <20081025222208.1d2a2c8b@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	torvalds@linux-foundation.org, "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50141 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881AbYJZFVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 01:21:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[resend, first version got corrupted]

2.6.28-rc1 broke my (intel 4965) wireless, and I've bisected it down to
the commit below..... something's fishy with this...


b2e1b30290539b344cbaff0d9da38012e03aa347 is first bad commit
commit b2e1b30290539b344cbaff0d9da38012e03aa347
Author: Luis R. Rodriguez <lrodriguez@atheros.com>
Date:   Tue Sep 9 23:19:48 2008 -0700

    cfg80211: Add new wireless regulatory infrastructure
    
    This adds the new wireless regulatory infrastructure. The
    main motiviation behind this was to centralize regulatory
    code as each driver was implementing their own regulatory solution,
    and to replace the initial centralized code we have where:
    
    * only 3 regulatory domains are supported: US, JP and EU
    * regulatory domains can only be changed through module parameter
    * all rules were built statically in the kernel
    
    We now have support for regulatory domains for many countries
    and regulatory domains are now queried through a userspace agent
    through udev allowing distributions to update regulatory rules
    without updating the kernel.
    
    Each driver can regulatory_hint() a regulatory domain
    based on either their EEPROM mapped regulatory domain value to a
    respective ISO/IEC 3166-1 country code or pass an internally built
    regulatory domain. We also add support to let the user set the
    regulatory domain through userspace in case of faulty EEPROMs to
    further help compliance.
  
    Support for world roaming will be added soon for cards capable of
    this.
    
    For more information see:
    
    http://wireless.kernel.org/en/developers/Regulatory/CRDA
    
    For now we leave an option to enable the old module parameter,
    ieee80211_regdom, and to build the 3 old regdomains statically
    (US, JP and EU). This option is CONFIG_WIRELESS_OLD_REGULATORY.
    These old static definitions and the module parameter is being
    scheduled for removal for 2.6.29. Note that if you use this
    you won't make use of a world regulatory domain as its pointless.
    If you leave this option enabled and if CRDA is present and you
    use US or JP we will try to ask CRDA to update us a regulatory
    domain for us.
    
    Signed-off-by: Luis R. Rodriguez <lrodriguez@atheros.com>
    Signed-off-by: John W. Linville <linville@tuxdriver.com>

-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org

-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
