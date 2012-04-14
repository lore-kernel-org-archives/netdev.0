From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/12] atl1c: remove VPD register
Date: Sat, 14 Apr 2012 14:43:05 -0400 (EDT)
Message-ID: <20120414.144305.2085076886038926579.davem@davemloft.net>
References: <1334397568-8444-1-git-send-email-xiong@qca.qualcomm.com>
	<1334397568-8444-5-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qca-linux-team@qualcomm.com, nic-devel@qualcomm.com
To: xiong@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334397568-8444-5-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: xiong <xiong@qca.qualcomm.com>
Date: Sat, 14 Apr 2012 17:59:20 +0800

> VPD register is only used for L1(devid=PCI_DEVICE_ID_ATTANSIC_L1) to
> access external NV-memory.
> l1c & later chip doesn't use it any more.
> no special userspace tool interpret the dumpped registers.
> dumpping them via ethtool is just for debug.
> 
> Signed-off-by: xiong <xiong@qca.qualcomm.com>
> Tested-by: Liu David <dwliu@qca.qualcomm.com>

I'm really disappointed that you're posting this patch again and
completely ignoring our feedback.

You're making this code buggy, and you're make me extremely irritated.

What's the point of our feedback if you just completely ignore it?

You can't crap up the register dump like this, you have to make
several modifications if you want to change the layout in any
way:

1) You have to adjust AT_REGS_LEN, because you're reporting one
   less register.

2) You have to adjust the offsets at the end of atl1c_get_regs(),
   the ones that explicitly use regs_buff[73] and regs_buf[74],
   otherwise you're leaving a gap between that area that's filled
   in using those p++ pointer increments and the entries filled
   in with these explicit offsets into reg_buff[].

3) You have to increment the register dump version, via the struct
   ethtool_regs 'version' field, so that userland programs can know
   that you've changed it.

So, tell me, are you going to completely ignore our feedback on
this issue again?
