From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/7] switchdev: add IPv4 routing offload
Date: Wed, 04 Mar 2015 16:06:04 -0500 (EST)
Message-ID: <20150304.160604.2259380248170644628.davem@davemloft.net>
References: <1425425520-34017-1-git-send-email-sfeldma@gmail.com>
	<20150304.003844.1400829201582760359.davem@davemloft.net>
	<CAE4R7bDBJye388V+itU9XqFNjruf0GcbXWFydx60fghiZp+NQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, roopa@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49588 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083AbbCDVGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 16:06:06 -0500
In-Reply-To: <CAE4R7bDBJye388V+itU9XqFNjruf0GcbXWFydx60fghiZp+NQw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>
Date: Tue, 3 Mar 2015 23:28:06 -0800

> On Tue, Mar 3, 2015 at 9:38 PM, David Miller <davem@davemloft.net> wrote:
> In v3, the setting and clearing of RTNH_F_EXTERNAL moved to the
> driver, the implementer of the add/del ndo ops.  So RTNH_F_EXTERNAL
> does get cleared by the driver on fib_flush_external().  We could add
> an additional clear above the driver, just in case the driver screwed
> up and forgot to clear it.  Driver bug in that case; not sure where to
> draw the line.

I'd rather the state bit get managed by net/ipv4/*.c rather than
duplicate this into every driver, that's error prone and duplicates
logic unnecessarily.

>> Secondly, if you call fib_flush_external() because an add returned an
>> error, you have to set some boolean state which prevents the next new
>> route insert from loading only that new route into the hardware
>> because that's exactly what will happen with your current
>> implementation.
> 
> I guess we could add a net.ipv4.fib_hw_screwed.  But that kills other
> innocent switch devices on same netns.  Or is it a private driver
> bool, which gets set on first install err, and is checked on
> subsequent installs?

You can make it per-netdevice if you want.  Put it into the inetdevice
area perhaps.
