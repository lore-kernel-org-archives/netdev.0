From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ucc_geth: Fix deadlock
Date: Fri, 12 Nov 2010 12:25:01 -0800 (PST)
Message-ID: <20101112.122501.260105076.davem@davemloft.net>
References: <1289570109-8160-1-git-send-email-Joakim.Tjernlund@transmode.se>
	<1289570109-8160-2-git-send-email-Joakim.Tjernlund@transmode.se>
	<20101112140947.GB28223@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Joakim.Tjernlund@transmode.se, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
To: cbouatmailru@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47690
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932661Ab0KLUYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 15:24:36 -0500
In-Reply-To: <20101112140947.GB28223@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <cbouatmailru@gmail.com>
Date: Fri, 12 Nov 2010 17:09:47 +0300

> On Fri, Nov 12, 2010 at 02:55:09PM +0100, Joakim Tjernlund wrote:
>> This script:
>>  while [ 1==1 ] ; do ifconfig eth0 up; usleep 1950000 ;ifconfig eth0 down; dmesg -c ;done
>> causes in just a second or two:
>> INFO: task ifconfig:572 blocked for more than 120 seconds.
> [...]
>> The reason appears to be ucc_geth_stop meets adjust_link as the
>> PHY reports PHY changes. I belive adjust_link hangs somewhere,
>> holding the PHY lock, because ucc_geth_stop disabled the
>> controller HW.
>> Fix is to stop the PHY before disabling the controller.
>> 
>> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> 
> It's unclear where exactly adjust_link() hangs, but the patch
> looks as the right thing overall.
> 
> Thanks!
> 
> Reviewed-by: Anton Vorontsov <cbouatmailru@gmail.com>

Applied.
