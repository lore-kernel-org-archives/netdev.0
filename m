From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next] net/ncsi: avoid maybe-uninitialized warning
Date: Fri, 22 Jul 2016 10:11:40 +1000
Message-ID: <20160722001140.GA9305@gwshan>
References: <20160721192927.3182806-1-arnd@arndb.de>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Gavin Shan <gwshan@linux.vnet.ibm.com>,
	Joel Stanley <joel@jms.id.au>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:54015 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752790AbcGVALu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 20:11:50 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6M08gMi051336
	for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 20:11:49 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24aeh5u6pe-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 20:11:49 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Fri, 22 Jul 2016 10:11:44 +1000
Content-Disposition: inline
In-Reply-To: <20160721192927.3182806-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 21, 2016 at 09:28:34PM +0200, Arnd Bergmann wrote:
>gcc-4.9 and higher warn about the newly added NSCI code:
>
>net/ncsi/ncsi-manage.c: In function 'ncsi_process_next_channel':
>net/ncsi/ncsi-manage.c:1003:2: error: 'old_state' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>
>The warning is a false positive and therefore harmless, but it would be good to
>avoid it anyway. I have determined that the barrier in the spin_unlock_irqsave()
>is what confuses gcc to the point that it cannot track whether the variable
>was unused or not.
>
>This rearranges the code in a way that makes it obvious to gcc that old_state
>is always initialized at the time of use, functionally this should not
>change anything.
>
>Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
