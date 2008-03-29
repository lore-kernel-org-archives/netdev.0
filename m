From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] 2.6.25-rc6 tulip_read_eeprom fixes for BUG 4420
Date: Fri, 28 Mar 2008 21:53:25 -0400
Message-ID: <47EDA115.1020200@pobox.com>
References: <20080324052310.GC474@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55080 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751548AbYC2Bx1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 21:53:27 -0400
In-Reply-To: <20080324052310.GC474@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Grundler wrote:
> Jeff,
> If "location" is > "addr_len" bits, the high bits of location would interfere
> with the READ_CMD sent to the eeprom controller.
> 
> A patch was submitted to bug:
>     http://bugzilla.kernel.org/show_bug.cgi?id=4420
> 
> which simply truncated the "location", read whatever was in "location
> modulo addr_len", and returned that value. That avoids confusing the
> eeprom but seems like the wrong solution to me.
> 
> Correct would be to not read beyond "1 << addr_len" address of the eeprom.
> I am submitting two changes to implement this:
> 1) tulip_read_eeprom will return zero (since we can't return -EINVAL)
>    if this is attempted (defensive programming).
> 2) In tulip_core.c, fix the tulip_read_eeprom caller so they don't
>    iterate past addr_len bits and make sure the entire tp->eeprom[]
>    array is cleared.
> 
> I konw we don't strictly need both. I would prefer both in the tree
> since it documents the issue and provides a second "defense" from
> the bug from creeping back in.
> 
> thanks,
> grant
> 
> Signed-off-by: Grant Grundler <grundler@parisc-linux.org>

applied, after manually removing "Jeff," and "thanks, grant" lines from 
the changelog ;-)


