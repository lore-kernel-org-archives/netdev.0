From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4 0/7] Refactor macvtap to re-use tap functionality by
 other virtual intefaces
Date: Tue, 07 Feb 2017 13:28:22 -0500 (EST)
Message-ID: <20170207.132822.668043461053676694.davem@davemloft.net>
References: <1486416975-14133-1-git-send-email-sainath.grandhi@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mahesh@bandewar.net,
        linux-kernel@vger.kernel.org
To: sainath.grandhi@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53612 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932067AbdBGS2Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 13:28:24 -0500
In-Reply-To: <1486416975-14133-1-git-send-email-sainath.grandhi@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sainath Grandhi <sainath.grandhi@intel.com>
Date: Mon,  6 Feb 2017 13:36:08 -0800

> Tap character devices can be implemented on other virtual interfaces like
> ipvlan, similar to macvtap. Source code for tap functionality in macvtap
> can be re-used for this purpose.
> 
> This patch series splits macvtap source into two modules, macvtap and tap.
> This patch series also includes a patch for implementing tap character
> device driver based on the IP-VLAN network interface, called ipvtap.
> 
> These patches are tested on x86 platform.

You're going to have to rework the module and Kconfig parts of this set
of changes.

The user should not have to modify any existing Kconfig setting to get
the same set of modules which already exist today.

Yet when I run "make oldconfig" after applying these changes it prompts
me for:

    TAP module support for virtual interfaces (TAP) [N/m/y/?] (NEW) 

And that's not really acceptable.  I had MACVTAP set, I should still get
the infrastructure necessary to get that module built.

If you want to do patch #6 you have to do it in a way that is transparent
to existing kernel configs.

Thanks.
