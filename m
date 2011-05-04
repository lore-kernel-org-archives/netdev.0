From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [ethtool PATCH 4/4] v5 Add RX packet classification interface
Date: Wed, 04 May 2011 11:50:42 -0700
Message-ID: <4DC1A002.1000606@chelsio.com>
References: <20110503160547.29251.84333.stgit@gitlad.jf.intel.com>	 <20110503161226.29251.40838.stgit@gitlad.jf.intel.com>	 <4DC08E7B.7070906@chelsio.com> <1304465684.2873.26.camel@bwh-desktop>	 <4DC1883F.7050301@chelsio.com> <1304529892.2926.14.camel@bwh-desktop> <4DC18DF8.3090707@chelsio.com> <4DC18FB2.8060604@intel.com> <4DC1986D.5020706@chelsio.com> <4DC19C78.9070308@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:14966 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048Ab1EDSuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 14:50:55 -0400
In-Reply-To: <4DC19C78.9070308@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2011 11:35 AM, Alexander Duyck wrote:
> On 5/4/2011 11:18 AM, Dimitris Michailidis wrote:
>> On 05/04/2011 10:41 AM, Alexander Duyck wrote:
>>> This is why I was suggesting that the best approach would be to update
>>> the kernel to add a separate ioctl for letting the driver setup the
>>> location.  We can just attempt to make that call and when we get the
>>> EOPNOTSUPP errno we know the device driver doesn't support it and can
>>> then let the rule manager take over.
>>
>> The problem with this is the location is dependent on the type of 
>> filter being
>> added.  I.e., the ioctl would need to get all the information the 
>> existing
>> ioctl carries making the new ioctl a small superset of the current one.
>> Additionally, if the driver only allocates a location in a separate 
>> ioctl how
>> does it know that the app is actually going to use it?
> 
> It doesn't know that the application is actually going to use it.  What 
> should happen is that the location should be verified by the driver when 
> it is used in the rule insertion call.  After all it is fully possible 
> for the user to specify a location out of range since the insert call 
> does no validation in ethtool if the user specified the location.  That 
> responsibility now lies with the driver.

That's not the problem I was pointing out.  Of course the driver will verify 
the location it is given.  The problem is if you have a separate ioctl call 
that only reserves a location (and it needs to reserve otherwise several of 
these calls can get the same value), if you don't use it you leave the driver 
with orphan reservations.  Imagine you hit ^C between the two ioctls in ethtool.

