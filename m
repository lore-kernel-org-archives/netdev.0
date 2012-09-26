From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: Ignore spurious UE indication from NIC
Date: Wed, 26 Sep 2012 19:33:06 -0400 (EDT)
Message-ID: <20120926.193306.1775779573258392844.davem@davemloft.net>
References: <20120921163620.GA6147@akhaparde-VBox>
	<20120921.150413.2303624982785706643.davem@davemloft.net>
	<3BB8C5C6B04A1F4CBE5B241DA98A501E67EC7B@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ajit.Khaparde@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48278 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141Ab2IZXdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 19:33:09 -0400
In-Reply-To: <3BB8C5C6B04A1F4CBE5B241DA98A501E67EC7B@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Khaparde, Ajit" <Ajit.Khaparde@Emulex.Com>
Date: Wed, 26 Sep 2012 22:35:14 +0000

>> From: David Miller [davem@davemloft.net]
>> Sent: Friday, September 21, 2012 2:04 PM
>> To: Khaparde, Ajit
>> Cc: netdev@vger.kernel.org
>> Subject: Re: [PATCH net-next] be2net: Ignore spurious UE indication from NIC
>>
>> From: Ajit Khaparde <ajit.khaparde@emulex.com>
>> Date: Fri, 21 Sep 2012 11:36:20 -0500
>>
>>> Ignore spurious UE indication seen on some platforms.
>>> Consider the error as un-recoverable only when the bits
>>> stay high during second sampling.
>>>
>>> Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
>>
>> Treating uncorrectable errors as spurious seems like an invitation
>> for hard to track down data corruption to me.
>>
>> You'll need to come up with a more sophisticated test for
>> spurious other than "happens more than once" before I'm willing
>> to subject the entire world to this kind of potential problem.
> 
> If the UE is real, then the hardware will stop responding to requests.
> The hardware block goes offline automatically and no traffic will flow.
> After this the hardware will generate a register dump, which can be
> retrived using ethtool.
> 
> A spurious UE or a data corruption will not generate this dump.
> 
> The detection logic is merely to inform the user about the failure
> and also avoid any further access to the NIC.

So it sounds more like the UE test should be removed completely
since you cannot rely upon it, and if a real UE happens the hardware
will stop and you will already report the problem when the hardware
block goes offline.

Furthermore, it also implies that you can test if the hardware block
is offline to validate the UE indication.

All of which says irrefutably that your patch is still the wrong way
to do this.
