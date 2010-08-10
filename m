From: Philip Rakity <prakity@marvell.com>
Subject: Re: [PATCH v2]  net: add Fast Ethernet driver for PXA168.
Date: Tue, 10 Aug 2010 11:12:45 -0700
Message-ID: <847F8195-87A2-4318-9E07-FF8A7E9FA1E6@marvell.com>
References: <EC64E4604C8024438259B683BB2514E1082B1CB1B0@SC-VEXCH1.marvell.com>
 <FE9BFA4C-11AB-46B9-A514-EB62467A1BB7@marvell.com>
 <1281429004.17990.2.camel@pe-lt522.marvell.com>
 <20100810123329.GR8876@mail.wantstofly.org>
 <7B1965FC-E61F-4BFD-86B1-F9D390A012CC@marvell.com>
 <20100810173052.GB25474@mail.wantstofly.org>
 <6546F80B-0B5E-4F41-A500-7B75493A42DE@marvell.com>
 <20100810180154.GD25474@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Sachin Sanap <ssanap@marvell.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Prabhanjan Sarnaik <sarnaik@marvell.com>,
	"eric.y.miao@gmail.com" <eric.y.miao@gmail.com>,
	Mark Brown <markb@marvell.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dakia3.marvell.com ([65.219.4.28]:45441 "EHLO
	dakia3.marvell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932271Ab0HJSMw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 14:12:52 -0400
In-Reply-To: <20100810180154.GD25474@mail.wantstofly.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Maybe the solution is to add a new option in Kconfig to define the extra headers size the driver will need.  That option will increase the headers.  I do not like that very much since it requires someone know how big the value should be.  Could default it to 48 or 64 bytes and allow it to be edited.   It is not great solution since it fixes the pxa168 driver but does not handle other drivers.  

thoughts ?



On Aug 10, 2010, at 11:01 AM, Lennert Buytenhek wrote:

> On Tue, Aug 10, 2010 at 10:55:02AM -0700, Philip Rakity wrote:
> 
>> We agree that extra header prepend space is needed.  The solution of
>> globally defining SKB_NET_PAD to increase this area for all drivers
>> is where I have some concern.  The solution certainly works but at
>> the cost of extra space for drivers that do not need to do this.
>> The solution is fine by me and maybe the best answer is to increase
>> the value in the standard linux implementation from 32 to 48 or 64 bytes. 
> 
> What I said was:
> 
> | This seems like something that, should you want to handle it, should be
> | handled centrally (e.g. by conditionally increasing NET_SKB_PAD or so)
> | and not hardcoded into one specific driver only.
> 
> In other words, "don't hardcode it into your driver just because you
> think that most users will want to use your driver for bridging/routing
> to wlan".
> 
> It makes no sense to categorically declare that "pxa168_eth will always
> be used for routing to wireless, so we'll add some extra headroom by
> default there, but e1000e will not, so there we won't".
> 
> Even if this stays a private kernel tree hack, I would still do it
> globally rather than locally.
> 
> 
>>>> 11n needs more.
>>> 
>>> Really?  Pointer?
> 
> Still curious about this.

will forward pointer reference later (on another computer)

