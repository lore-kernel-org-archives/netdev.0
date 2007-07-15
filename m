From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/3] s390: iucv - avoid deadlock between
 iucv_path_connect and tasklet
Date: Sat, 14 Jul 2007 19:03:50 -0700 (PDT)
Message-ID: <20070714.190350.95894917.davem@davemloft.net>
References: <20070713085053.530802000@linux.vnet.ibm.com>
	<20070713085245.495093000@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	fpavlic@de.ibm.com
To: braunu@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49824
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932274AbXGOCDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 22:03:48 -0400
In-Reply-To: <20070713085245.495093000@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <braunu@de.ibm.com>
Date: Fri, 13 Jul 2007 10:50:55 +0200

> From: Ursula Braun <braunu@de.ibm.com>
> 
> An iucv deadlock may occur, where one CPU is spinning on the
> iucv_table_lock for iucv_tasklet_fn(), while another CPU is holding
> the iucv_table_lock for an iucv_path_connect() and is waiting for
> the first CPU in an smp_call_function.
> Solution: replace spin_lock in iucv_tasklet_fn by spin_trylock and
> reschedule tasklet in case of non-granted lock.
> 
> Signed-off-by: Ursula Braun <braunu@de.ibm.com>
> Acked-by: Frank Pavlic <fpavlic@de.ibm.com>

Applied.
