From: "Khaparde, Ajit" <Ajit.Khaparde@Emulex.Com>
Subject: RE: [PATCH net-next] be2net: Ignore spurious UE indication from NIC
Date: Wed, 26 Sep 2012 22:35:14 +0000
Message-ID: <3BB8C5C6B04A1F4CBE5B241DA98A501E67EC7B@CMEXMB1.ad.emulex.com>
References: <20120921163620.GA6147@akhaparde-VBox>,<20120921.150413.2303624982785706643.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:46826 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752889Ab2IZWfQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 18:35:16 -0400
In-Reply-To: <20120921.150413.2303624982785706643.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller [davem@davemloft.net]
> Sent: Friday, September 21, 2012 2:04 PM
> To: Khaparde, Ajit
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH net-next] be2net: Ignore spurious UE indication from NIC
>
> From: Ajit Khaparde <ajit.khaparde@emulex.com>
> Date: Fri, 21 Sep 2012 11:36:20 -0500
>
>> Ignore spurious UE indication seen on some platforms.
>> Consider the error as un-recoverable only when the bits
>> stay high during second sampling.
>>
>> Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
>
> Treating uncorrectable errors as spurious seems like an invitation
> for hard to track down data corruption to me.
>
> You'll need to come up with a more sophisticated test for
> spurious other than "happens more than once" before I'm willing
> to subject the entire world to this kind of potential problem.

If the UE is real, then the hardware will stop responding to requests.
The hardware block goes offline automatically and no traffic will flow.
After this the hardware will generate a register dump, which can be
retrived using ethtool.

A spurious UE or a data corruption will not generate this dump.

The detection logic is merely to inform the user about the failure
and also avoid any further access to the NIC. This will also prevent
the driver unload from having to timeout on each access to the hardware
which could take a long time to complete.

Please let me know if this is enough to differentiate the scenarios.

Thanks
-Ajit