From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb{3,4}: streamline Kconfig options
Date: Mon, 28 Feb 2011 13:19:10 -0800 (PST)
Message-ID: <20110228.131910.242129416.davem@davemloft.net>
References: <4D66B45B.2050604@chelsio.com>
	<4D680842.6050309@chelsio.com>
	<4D6B68BE020000780003402E@vpn.id2.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dm@chelsio.com, divy@chelsio.com, linux-kbuild@vger.kernel.org,
	netdev@vger.kernel.org
To: JBeulich@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43786
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754838Ab1B1VSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 16:18:33 -0500
In-Reply-To: <4D6B68BE020000780003402E@vpn.id2.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jan Beulich" <JBeulich@novell.com>
Date: Mon, 28 Feb 2011 08:19:58 +0000

>>>> On 25.02.11 at 20:51, Dimitris Michailidis <dm@chelsio.com> wrote:
>> Dimitris Michailidis wrote:
>>> Jan Beulich wrote:
>>> 
>>>> As to that INET vs NET dependency - is it possible that the
>>>> network drivers really just need NET, but the iSCSI ones need
>>>> INET? In which case the only common dependency would be
>>>> PCI - certainly not worth a custom helper option.
>>> 
>>> Reading the commit message that introduced CHELSIO_T3_DEPENDS, it talks 
>>> of hidden dependencies that select does not see.  I am not sure which 
>>> exactly but since it's been a few years since that commit I'll try to 
>>> see what the situation is today without the *_DEPENDS symbols and let 
>>> you know.
>> 
>> I looked into this and found that with the current Kconfig the iSCSI driver 
>> does not appear in the SCSI menu until one first enables NETDEVICES and 
>> NETDEV_10000 in the network driver menu.  It appears that the *_DEPENDS 
>> symbols were added to capture dependencies on such symbols within the 
>> network driver Kconfig, besides the dependencies the driver's entry listed 
>> explicitly.
>> 
>> The patch below removes *T4*_DEPENDS and the network drivers' unnecessary 
>> dependency on INET, and updates the iSCSI driver's entry so it is visible 
>> without requiring any net driver options to be enabled first and has 
>> adequate selects to be able to build the net driver (this part is adapted 
>> from bnx2i's Kconfig entry).  I still need to do the T3 part of this and 
>> check that there isn't a conflict with the current scsi tree.  Just for 
>> review at this time.
> 
> Thanks, this looks good to me.

Dimitris, please submit this anew with a proper commit log messag and
signoff.  Thanks.
