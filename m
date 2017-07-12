From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] igb: fix unused igb_deliver_wake_packet() warning when
 CONFIG_PM=n
Date: Wed, 12 Jul 2017 14:37:57 -0700 (PDT)
Message-ID: <20170712.143757.39770380256592298.davem@davemloft.net>
References: <20170712210925.4F647FAA@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: dave.hansen@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170712210925.4F647FAA@viggo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 12 Jul 2017 14:09:25 -0700

> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> I'm seeing warnings on kernel configurations where CONFIG_PM is
> disabled.  It happens in 4.12, at least:
> 
> drivers/ethernet/intel/igb/igb_main.c:7988:13: warning: 'igb_deliver_wake_packet' defined but not used [-Wunused-function]
> 
> This is because igb_deliver_wake_packet() is defined outside of
> the #ifdef", but is used only a single time within the #ifdef in
> igb_resume().  Fix it by moving igb_deliver_wake_packet() next to
> igb_resume() inside the #ifdef.
> 
> The diff ends up looking a bit funky here.  It *looks* like
> igb_suspend() is getting moved, but that's an artifact of how
> 'diff' sees the changes.
> 
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: intel-wired-lan@lists.osuosl.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

I'll let Jeff queue this up into his tree.
