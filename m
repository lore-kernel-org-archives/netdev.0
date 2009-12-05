From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Modify return value for the .ndo_set_mac_address
Date: Sat, 05 Dec 2009 14:32:55 -0800 (PST)
Message-ID: <20091205.143255.216248367.davem@davemloft.net>
References: <20091204114721.GA5505@coldcone>
	<20091204.133018.10228592.davem@davemloft.net>
	<20091205192926.GA4031@coldcone>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "kirjanov@gmail.com"@sunset.davemloft.net.davemloft.net,
	kirjanov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42590
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756698AbZLEWcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2009 17:32:48 -0500
In-Reply-To: <20091205192926.GA4031@coldcone>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
Date: Sat, 5 Dec 2009 22:29:26 +0300

> On Fri, Dec 04, 2009 at 13:30 -0800, David Miller wrote:
>> From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
>> Date: Fri, 4 Dec 2009 14:47:22 +0300
>> 
>> > Return -EADDRNOTAVAIL insted of -EINVAL in .ndo_set_mac_address.
>> > 
>> > Signed-off-by: Denis Kirjanov <kirjanov@gmail.com>
>> 
>> Why?
>> 
>> The address is "invalid" so we return "invalid" error.
>> 
>> What's the problem?
>> 
>> And whether there is a good reason or not, your commit message did not
>> describe that reason so needs to be updated.

Will you please talk to me instead of just responding in the
commit message itself?  I want to have a real conversation about
this.

> Some drivers in drivers/net return -EINVAL in .ndo_set_mac_address,
> but some -EADDRNOTAVAIL. Thus, we use
> "Cannot assign requested address" in the case of setting up new hw address
> to be more consistent across drivers/net in
> .ndo_set_mac_address function.

This doesn't by itself make EADDRNOTAVAIL a better choice.

If you look elsewhere, this error code is used in cases where
tries to use  an address is not configured on a device or a
socket.

This is different than the usage you are trying to make the
tree use consistently here.

I still think -EINVAL makes more sense.

Yes it is a problem that UNIX lacks more verbose and precise error
code specifications, but that itself should be attacked as a problem
rather than used as a reason to choose EADDRNOTAVAIL as an
error code here.

I'm not applying your patches, I do not agree with your reasoning.
I still think -EINVAL is better, and therefore you still need to
respin your other patch.

