From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlge: Fix a deadlock when the interface is going down
Date: Wed, 25 Aug 2010 16:38:51 -0700 (PDT)
Message-ID: <20100825.163851.116362795.davem@davemloft.net>
References: <1282690240-5301-1-git-send-email-leitao@linux.vnet.ibm.com>
	<20100825144230.GA12700@linux-ox1b.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59331
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754215Ab0HYXif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 19:38:35 -0400
In-Reply-To: <20100825144230.GA12700@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Wed, 25 Aug 2010 07:42:30 -0700

> On Tue, Aug 24, 2010 at 03:50:40PM -0700, leitao@linux.vnet.ibm.com wrote:
>> Currently qlge can deadlock when the interface is going
>> down, and the mpi_port_cfg_work() is executing on another
>> processor. It happens because unregister_netdev() holds
>> the rtnl lock, and the mpi_port_cfg_work() also request
>> this lock.
>> 
>> Since unregiter_netdev() may wait mpi_port_cfg_work(), who
>> also request the holding lock, it can cause an deadlock,
>> displaying the following error:
>> 
> 
> Thanks Breno.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.
