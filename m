From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH] lro: IP fragment checking
Date: Mon, 01 Dec 2008 19:02:19 -0500
Message-ID: <49347B0B.8030705@myri.com>
References: <4933A74F.3050809@de.ibm.com>	<493423D7.5030203@myri.com>	 <20081201.131810.158631503.davem@davemloft.net> <49345CCA.1030209@myri.com> <1228169379.3073.13.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ossthema@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tklein@de.ibm.com, raisch@de.ibm.com, jb.billaud@gmail.com,
	hering2@de.ibm.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1890 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751068AbYLBACh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2008 19:02:37 -0500
In-Reply-To: <1228169379.3073.13.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> On Mon, 2008-12-01 at 16:53 -0500, Andrew Gallatin wrote:
>> David Miller wrote:
>>> From: Andrew Gallatin <gallatin@myri.com>
>>> Date: Mon, 01 Dec 2008 12:50:15 -0500
>>>
>>>> As to whether or not to do it in the drivers/hardware or in the
>>>> LRO code, I favor doing it in the LRO code just so that it is not
>>>> missed in some driver.
>>> Then there is no point in the hardware doing the check, if
>>> we're going to check it anyways.
>>>
>>> That's part of my point about why this check doesn't belong
>>> here.
>> What hardware does an explicit check for fragmentation?
> 
> Any that implements TCP/UDP checksumming properly.

How many do?

>> In most cases, aren't we just relying on the hardware checksum
>> to be wrong on fragmented packets? That works 99.999% of the time,
>> but the TCP checksum is pretty weak, and it is possible to
>> have a fragmented packet where the first fragment has the same
>> checksum as the entire packet.
> [...]
> 
> If your hardware/firmware wrongly claims to be able to verify the
> TCP/UDP checksum for an IP fragment, it seems to me you should deal with
> that in your driver or fix the firmware.

We do partial checksums.

Drew
