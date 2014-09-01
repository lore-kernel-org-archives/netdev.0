From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Configure device endianity on driver load
 and reset endianity on removal.
Date: Mon, 01 Sep 2014 14:53:14 -0700 (PDT)
Message-ID: <20140901.145314.1237097170646182877.davem@davemloft.net>
References: <1409581043-25357-1-git-send-email-manish.chopra@qlogic.com>
	<31AFFC7280259C4184970ABA9AFE8B93E0800207@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Yuval.Mintz@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44479 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbaIAVxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 17:53:15 -0400
In-Reply-To: <31AFFC7280259C4184970ABA9AFE8B93E0800207@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Mon, 1 Sep 2014 15:33:20 +0000

>> -----Original Message-----
>> This patch fixes this case from both ends:
>> 1) Return endianity to original values on shutdown (in case little endian kernel
>> boots after we shutdown).
>> 2) Do not rely on HW reset values when loading driver in little endian kernel
>>    but configure them explicitly (in case previous kernel was big endian and did
>> not reset the HW).
 ...
> David, Please drop this patch as it might create issue for VFs.
> I will send updated V2 patch with proper fix. 

I think part #2 is the only reasonable part of this patch, and that's
what you'll have to backport to -stable kernels to sort this out
properly.

Adding "unconfiguration" hacks into a driver to deal with driver bugs
is really not kosher, sorry.
