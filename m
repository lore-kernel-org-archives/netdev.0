From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [REGRESSION] r8169: jumbo fixes caused jumbo regressions!
Date: Tue, 13 Nov 2012 23:35:12 +0100
Message-ID: <20121113223512.GA29342@electric-eye.fr.zoreil.com>
References: <20121113170655.GA20291@tugrik.mns.mnsspb.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org
To: Kirill Smelkov <kirr@mns.spb.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:46402 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753683Ab2KMW6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 17:58:30 -0500
Content-Disposition: inline
In-Reply-To: <20121113170655.GA20291@tugrik.mns.mnsspb.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kirill Smelkov <kirr@mns.spb.ru> :
[...]
> My test is to stream raw video from 8 PAL cameras to net - 4 for 720x576@25 and
> 4 for 360x288@25 which for YUYV format occupies ~ 860 Mbps of bandwidth. The
> program to transmit/receive video is here: http://repo.or.cz/w/rawv.git

$ git clone  http://repo.or.cz/w/rawv.git
Cloning into 'rawv'...
fatal: http://repo.or.cz/w/rawv.git/info/refs not valid: is this a git repository?

[...]
> (by the way, on atom system, without tx csum offload, half of cpu time
> is spent only to calculate checksums...)

:o(

> Now I wonder, where that 6K limit came from and why they say it is now
> not possible to use jumbos together with tx csum offload ?

Here is an excerpt from a mail where Hayes explained the rules of
engagement back in may 2011 (John Lumby and Chris Friesen were Cced then):

! The Max tx sizes for 8168 series are as following:
! 
! 8168B is 4K bytes.
! 8168C and 8168CP are 6K bytes.
! 8168D and later are 9K bytes.
! 
! Note that these sizes all include head size. That is, the mtu must less than
! these values.
! You have to enable Jumbo frame feature when the tx size is large, otherwise the
! packet would not be sent. Because the hw doesn't provide the threshold, the
! checking for MTU > 1500 is just for convenience for sw.
! 
! The TSO couldn't work with some feature which need to disable hw checksum, such
! as Jumbo frame. The hw checksum have to be disabled in certain situations, so
! the TSO feature should be checked in these situations, too.

> Is my testing enough to justify raising the limits and allowing tx offload ?

I don't oppose knobs to go off-limits but I'll need some rather good reason
before changing the manufacturer's suggested defaults.

-- 
Ueimor
