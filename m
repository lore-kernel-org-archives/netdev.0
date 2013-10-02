From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/11] igb: Avoid uninitialized advertised variable in
 eee_set_cur
Date: Wed, 02 Oct 2013 16:33:19 -0400 (EDT)
Message-ID: <20131002.163319.1718353534049561226.davem@davemloft.net>
References: <1380572952-30729-1-git-send-email-andi@firstfloor.org>
	<1380572952-30729-8-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ak@linux.intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380572952-30729-8-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Mon, 30 Sep 2013 13:29:08 -0700

> From: Andi Kleen <ak@linux.intel.com>
> 
> eee_get_cur assumes that the output data is already zeroed. It can
> read-modify-write the advertised field:
> 
>               if (ipcnfg & E1000_IPCNFG_EEE_100M_AN)
> 2594			edata->advertised |= ADVERTISED_100baseT_Full;
> 
> This is ok for the normal ethtool eee_get call, which always
> zeroes the input data before.
> 
> But eee_set_cur also calls eee_get_cur and it did not zero the input
> field. Later on it then compares agsinst the field, which can contain partial
> stack garbage.
> 
> Zero the input field in eee_set_cur() too.
> 
> Cc: jeffrey.t.kirsher@intel.com
> Cc: netdev@vger.kernel.org
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Applied.
