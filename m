From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Wed, 15 Apr 2009 03:02:13 -0700 (PDT)
Message-ID: <20090415.030213.249634462.davem@davemloft.net>
References: <20090415100937.4b08ce28@dhcp-lab-109.englab.brq.redhat.com>
	<20090415.022809.90182032.davem@davemloft.net>
	<49E5AD56.6020701@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, netdev@vger.kernel.org, gallatin@myri.com
To: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58228
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756710AbZDOKCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 06:02:22 -0400
In-Reply-To: <49E5AD56.6020701@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brice Goglin <brice@myri.com>
Date: Wed, 15 Apr 2009 11:48:06 +0200

> David Miller wrote:
>> From: Stanislaw Gruszka <sgruszka@redhat.com>
>> Date: Wed, 15 Apr 2009 10:09:37 +0200
>>
>>   
>>> Add LRO alignment initially committed in 621544eb8c3beaa859c75850f816dd9b056a00a3
>>> and removed in 0dcffac1a329be69bab0ac604bf7283737108e68 during conversion to
>>> multi-slice.
>>>
>>> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
>>>     
>>
>> Applied, thanks.
>>
>> Please, in the future, add the header string of the commit message
>> when referencing GIT commits.  When this patch is added to the -stable
>> kernel or similar the GIT commit ideas might be different and it
>> will be impossible for someone reading your commit message to find
>> the referenced commit using only the SHA ID.
>>   
> 
> I guess we need to send this patch to the stable maintainers since it
> should affect 2.6.27, .28 and .29.

I will queue it up for -stable, you just have to ask me to do
that.

> Is there a good summary somewhere of why GRO is better,

Transparent forwarding/bridging support, easier driver port.

> and how to
> actually convert drivers?

Step 1: Remove all of your LRO support code, every last line
Step 2: netif_receive_skb() --> napi_gro_receive()
        vlan_hwaccel_rx() --> vlan_gro_receive()

It couldn't be any easier.

And it would also behoove you to look at the commits that converted or
added GRO support to other drivers.  That's how I learned it :-)
