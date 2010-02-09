From: Anatolij Gustschin <agust@denx.de>
Subject: Re: [net-next-2.6 PATCH 2/3] fs_enet: Add support for MPC512x to
 fs_enet driver
Date: Tue, 9 Feb 2010 15:23:17 +0100
Message-ID: <20100209152317.5303b1b3@wker>
References: <1264039999-25731-3-git-send-email-agust@denx.de>
	<20100121.012235.161201297.davem@davemloft.net>
	<4B5871F2.9090005@grandegger.com>
	<20100121.180311.228791894.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, netdev@vger.kernel.org, dzu@denx.de, wd@denx.de,
	jcrigby@gmail.com, kosmo@semihalf.com, linuxppc-dev@ozlabs.org,
	grant.likely@secretlab.ca
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:56665 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753361Ab0BIOXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 09:23:40 -0500
In-Reply-To: <20100121.180311.228791894.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Jan 2010 18:03:11 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Wolfgang Grandegger <wg@grandegger.com>
> Date: Thu, 21 Jan 2010 16:25:38 +0100
> 
> > Do you see a more clever solution to this problem?
> 
> See how we handle this in the ESP scsi driver.  We have a set of
> defines for the register offsets, and a set of methods a chip driver
> implements for register accesses.
> 
> If the offsets differ, the register access method can translate the
> generic register offsets into whatever layout their implementation
> actually uses.

First of all thanks for your suggestion. I have seen how you
handle register access in the ESP scsi driver. The reason I didn't
try to implement register access using similar approach is that
we have different sort of problem.

In my understanding, in the ESP scsi driver the set of defines for
the register offsets is common for all chip drivers. The chip driver
methods for register access translate the offsets because the
registers on some chips are at different intervals (4-byte, 1-byte,
16-byte for mac_esp.c). But the register order is the same for
different chips.

In our case non only the register order is not the same for 8xx
FEC and 5121 FEC, but there are also other differences, different
reserved areas between several registers, some registers are
available only on 8xx and some only on 5121.

Now at least tree people suggested to fork the driver. My question
is if you would accept a forked 5121 FEC specific driver realised
similar to drivers/net/fs_enet/mac-fec.c and
drivers/net/fs_enet/mii-fec.c drivers?
 
Thanks,

Anatolij
