From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next 1/3] xen-netback: page pool support
Date: Fri, 24 May 2013 13:44:31 +0100
Message-ID: <519F60AF.5020705@citrix.com>
References: <1369391553-16835-1-git-send-email-wei.liu2@citrix.com> <1369391553-16835-2-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<ian.campbell@citrix.com>, <konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:29431 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248Ab3EXMoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 08:44:34 -0400
In-Reply-To: <1369391553-16835-2-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/05/13 11:32, Wei Liu wrote:
> This patch implements a page pool for all vifs. It has two functionalities:
>  a) to limit the amount of pages used by all vifs
>  b) to track pages belong to vifs

This adds a global spin lock.  This doesn't seem very scalable.

It's also not clear how this is usefully limiting the memory usage by
guest network traffic.  It limits the number of pages that netback can
use during the grant copy from the guest pages but this is only short
time compared to the lifetime of the network packet within the rest of
the network stack.

If you didn't have this page pool stuff then each thread/VIF is limited
to at most 256 pages anyway and I think 1 MiB of memory per VIF is
perfectly acceptable.

David
