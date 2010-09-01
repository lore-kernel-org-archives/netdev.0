From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: ERR_PTR pattern in phylib
Date: Wed, 1 Sep 2010 12:56:29 -0600
Message-ID: <AANLkTimkh6ytDmiCQY-gZLHpLzeux1RwMFyr=HyfcDaJ@mail.gmail.com>
References: <AANLkTimjVZTNeLdm4qptU1MqREODLASdGGanUyxqxfub@mail.gmail.com> <20100901.082729.135524471.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: afleming@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:37948 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754954Ab0IAS4u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 14:56:50 -0400
Received: by gyd8 with SMTP id 8so3147120gyd.19
        for <netdev@vger.kernel.org>; Wed, 01 Sep 2010 11:56:49 -0700 (PDT)
In-Reply-To: <20100901.082729.135524471.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 1, 2010 at 9:27 AM, David Miller <davem@davemloft.net> wrot=
e:
> From: Grant Likely <grant.likely@secretlab.ca>
> Date: Wed, 1 Sep 2010 08:42:49 -0600
>
>> It seems to me that phylib is one of the cases where the users (the
>> network drivers) don't actually care about the specific error code
>> when calling phylib functions. =A0The drivers only seem to care whet=
her
>> or not the function failed, and if it did then bail out. =A0I've als=
o
>> noticed that using the "if (!ptr)" test on phylib return values is a
>> common error for driver writers.
>>
>> In the interest of making driver code easier to write and review,
>> would you be opposed to a set of patches to remove the ERR_PTR()
>> pattern from phylib and its users?
>
> I'm opposed to it because it means that if code actually does
> care about the error code it will no longer be able to obtain
> it.

The error codes in phylib are almost arbitrary and don't really give
enough information about where the a failure lies.  dev_err() is more
useful for debugging.

My experience has been that the encoding of error numbers into a
pointer return is a source of bugs for driver writers and should be
strongly avoided unless the return codes are actually important (ie.
userspace depends on them).  Especially so when the use-case for
keeping them is merely theoretical.  I've looked through the phylib
usage for ERR_PTR(), and it all is related to whether or not a
phy_device pointer can be located.  The error code is pretty much
irrelevant if a phy cannot be obtained.

How about this as a compromise:  I'll investigate all the users of
phylib and if I find even one situation where the specific return code
is actually important to a driver, then I'll back off.  phylib has
been around for 5 years now which should be enough time for that use
case to bubble to the surface.

g.
