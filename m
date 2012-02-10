From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [patch] bna: fix error handling of
 bnad_get_flash_partition_by_offset()
Date: Thu, 9 Feb 2012 17:53:20 -0800
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86B1FB8B0A20@HQ1-EXCH01.corp.brocade.com>
References: <20120209104934.GC5540@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	"Adapter Linux Open SRC Team"
	<adapter_linux_open_src_team@Brocade.COM>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:52025 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758142Ab2BJCoJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Feb 2012 21:44:09 -0500
In-Reply-To: <20120209104934.GC5540@elgon.mountain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Dan Carpenter [mailto:dan.carpenter@oracle.com]
>Sent: Thursday, February 09, 2012 2:50 AM
>
>The current error handling doesn't work because we flash_part is a u32
>so the checks for negative error codes don't work.  I considered making
>things signed but I don't know the hardware enough to say if that's a
>problem.  Really, we don't use the error codes so just returning zero
>for all problems is fine.

Hi Dan,

We can't return 0 from the bnad_get_flash_partition_by_offset() on error as the flash partition 0 is a optrom partition. Also we got comments to return proper Linux error codes as ethtool application expects so.

What we can do is change the return type of the bnad_get_flash_partition_by_offset() to int.

Thanks,
Rasesh
