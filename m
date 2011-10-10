From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4_en: fix endianness with blue frame support
Date: Mon, 10 Oct 2011 14:10:53 -0400 (EDT)
Message-ID: <20111010.141053.1739730804108789791.davem@davemloft.net>
References: <1318231920.29415.404.camel@pasglop>
	<1318264943-10009-1-git-send-email-cascardo@linux.vnet.ibm.com>
	<20111010164654.GA3648@oc1711230544.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	eli@dev.mellanox.co.il, yevgenyp@mellanox.co.il,
	benh@kernel.crashing.org
To: cascardo@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36354 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388Ab1JJSNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 14:13:14 -0400
In-Reply-To: <20111010164654.GA3648@oc1711230544.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Date: Mon, 10 Oct 2011 13:46:54 -0300

> On Mon, Oct 10, 2011 at 01:42:23PM -0300, Thadeu Lima de Souza Cascardo wrote:
>> The doorbell register was being unconditionally swapped. In x86, that
>> meant it was being swapped to BE and written to the descriptor and to
>> memory, depending on the case of blue frame support or writing to
>> doorbell register. On PPC, this meant it was being swapped to LE and
>> then swapped back to BE while writing to the register. But in the blue
>> frame case, it was being written as LE to the descriptor.
>> 
>> The fix is not to swap doorbell unconditionally, write it to the
>> register as BE and convert it to BE when writing it to the descriptor.
>> 
>> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
>> Reported-by: Richard Hendrickson <richhend@us.ibm.com>
>> Cc: Eli Cohen <eli@dev.mellanox.co.il>
>> Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
>> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> ---
> 
> So I tested this patch and it works for me. Thanks Ben and Eli for
> finding out the problem with doorbell in the descriptor.

Applied, thanks everyone.
