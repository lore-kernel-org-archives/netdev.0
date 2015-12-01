From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: xgene: fix Tx flow control
Date: Tue, 01 Dec 2015 15:21:27 -0500 (EST)
Message-ID: <20151201.152127.1326770277234261993.davem@davemloft.net>
References: <1448680951-4730-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@apm.com, kdinh@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755046AbbLAUV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 15:21:29 -0500
In-Reply-To: <1448680951-4730-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Fri, 27 Nov 2015 19:22:31 -0800

> Currently the Tx flow control is based on reading the hardware state,
> which is not accurate since it may not reflect the descriptors that
> are not yet reached the memory.
> 
> To accurately control the Tx flow, changing it to be software based.
> 
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> Tested-by: Khuong Dinh <kdinh@apm.com>

Having a new atomic operation for every completion descriptor
operation is very excessive.

Especially when there is probably some other lock being held in all
of these paths upon which you can use for synchornization.
