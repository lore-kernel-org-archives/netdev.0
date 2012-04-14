From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/37] atl1c: remove VPD register
Date: Fri, 13 Apr 2012 20:45:51 -0400 (EDT)
Message-ID: <20120413.204551.959091962456153270.davem@davemloft.net>
References: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
	<1334276102-15866-5-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qca-linux-team@qualcomm.com, nic-devel@qualcomm.com
To: xiong@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334276102-15866-5-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: xiong <xiong@qca.qualcomm.com>
Date: Fri, 13 Apr 2012 08:14:29 +0800

> VPD register is only used for L1(devid=PCI_DEVICE_ID_ATTANSIC_L1) to
> access external NV-memory.
> l1c & later chip doesn't use it any more.
> 
> Signed-off-by: xiong <xiong@qca.qualcomm.com>
> Tested-by: Liu David <dwliu@qca.qualcomm.com>

You just broke ethtool register dumps with this change.

Now, all the initial registers are reported offset by one entry, yet
the last two are still reported in their original spots.

This layout is exposed to userspace, and interpreted by tools, and you
cannot change it.

If this register always reports some value, you should just keep it
there in the dumps.

I think you guys are way too aggressively removing things from the
driver.

You are also posting way too many patches at one time.

If you post so many patches at once, if one of the early patches
have a problem (as already is the case here) it means all the
rest of your patches will not apply without offsets or rejects
and therefore will all need to be redone and resubmitted.

Posting too many patches at once also creates a large burdon for
those who will choose to help review your changes.

Send a small, reasonable, number of patches at one time.  Say,
for example, 10 or 15 maximum.
