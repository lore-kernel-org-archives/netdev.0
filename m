From: Jing Huang <huangj@Brocade.COM>
Subject: RE: [PATCH 0/7] bna: Update driver version to 3.0.23.0 (resubmit)
Date: Wed, 4 Apr 2012 16:07:22 -0700
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86B3A74DEE55@HQ1-EXCH01.corp.brocade.com>
References: <1333554102-21973-1-git-send-email-huangj@brocade.com>
 <20120404.182105.1576892492865932011.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Adapter Linux Open Src Ext Team"
	<AdapterLinuxOpenSrcExtTeam@Brocade.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:36020 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757211Ab2DDXHd convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 19:07:33 -0400
In-Reply-To: <20120404.182105.1576892492865932011.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>But I would suggest modifying how the driver spins waiting for the
>firmware to release semaphore bits in registers.
>
>You have no timeouts or limits in these loops.
>
>So if the firmware crashes or gets stuck, this will take out the
>entire computer which is very undesirable.
>
>Change these loops to have a limit and signal an error and fail the
>top-level operation if the limit is hit.

Thanks David.

The ioc init semaphore register is only used by driver. Firmware will never touch this
register.  It will only be set to 1 when there is a driver instance holding it. So in practice, 
the infinite look will happen only if a driver instance grab the semaphore but forgot to
release it. We add this logic to serialize register access for potential case of concurrent PCI
function probe, which seems pretty rare in Linux.

I agree that this code looks ugly and wrong in theory. We will consider remove it or
implement some timeout logic for it.

Jing
