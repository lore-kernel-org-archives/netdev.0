From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: Re: [PATCH] 2.6 driver for Silan SC92031
Date: Sat, 02 Dec 2006 22:23:05 -0200
Message-ID: <457218E9.7070902@cesarb.net>
References: <4571FC49.5060208@cesarb.net> <4571FDE7.9060203@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-02.mandic.com.br ([200.225.81.133]:34999 "EHLO
	smtp-02.mandic.com.br") by vger.kernel.org with ESMTP
	id S1424727AbWLCAXM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Dec 2006 19:23:12 -0500
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4571FDE7.9060203@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik escreveu:
> Cesar Eduardo Barros wrote:
>> From: Cesar Eduardo Barros <cesarb@cesarb.net>
>>
>> This is a driver for the Silan SC92031/Rsltek 8139D NIC chip. It's a
>> rewrite of the vendor 2.4 driver for 2.6, and has been lightly tested
>> on a 2.6.17 x86-64 kernel with the Ubuntu patches (as a out-of-tree
>> module only).
>>
> 
> Seems like it would be best to modify the existing 8139 driver...

I'm not sure it would help. Either the hardware differences are too 
large (for instance, the MII/link part, where the way the vendor driver 
did things implies the MII has only the two basic registers plus two 
vendor registers, meaning I simply cannot use the generic mii code) or 
the code is already modified from the 8139 driver (the vendor driver 
seems to be based on an old version of either pci-skeleton.c or 
8139too.c, and I based my rewrite on the vendor driver).

Of course, one thing I probably will copy from 8139too.c later is the 
NAPI code; I wanted to avoid the extra locking complexity in this first 
version (the fact that the interrupt status register is cleared on 
reading only makes things more complex). If you can suggest other things 
to copy, it would be good, since the copied code is less likely to be wrong.

-- 
Cesar Eduardo Barros
cesarb@cesarb.net
cesar.barros@gmail.com
