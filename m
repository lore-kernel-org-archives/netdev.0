From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 1/1] ethtool: adding support for multiple slave port
 configuration
Date: Sun, 27 Jul 2014 09:09:54 -0700
Message-ID: <53D52452.2020300@gmail.com>
References: <1406291305-22286-1-git-send-email-mugunthanvnm@ti.com> <1406429221.29010.151.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-api@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:43798 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745AbaG0QKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jul 2014 12:10:11 -0400
In-Reply-To: <1406429221.29010.151.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/26/2014 07:47 PM, Ben Hutchings wrote:
> On Fri, 2014-07-25 at 17:58 +0530, Mugunthan V N wrote:
>> Some Ethernet Swtich controllers like CPSW in AM335x, TI814x, DRA7x and
>> AM43xx SoCs, Network Coprocessor in AM5K2E0x, Realtek Switch controllers
>> etc has to capability of conneting multiple networks using L2 switching
>> and has multiple phys. With the existing code, ethtool can communicate
>> only to one phy.
>>
>> To enable user to communicate multiple phy connected to single Ethernet
>> Switch controller, intoducing a optional new parameter in Ethtool interface
>> to pass which slave to set/get the phy configuration.
>
> There was some discussion about configuration APIs for hardware/firmware
> bridges earlier this year and I thought there was a consensus for
> assigning a network device to each port.  This would remove the need to
> identify ports within a device.  But I may have misremembered.
>

I like the approach of creating a network device for each port over
having to use ethtool to program/discover them. I am currently looking
at writing management applications for this and IMO it is much easier
to discover and listen for events on network devices vs polling ethtool
and iterating through slave indexs. Also you miss a lot of functionality
that may be useful MTU for example that is not available configured via
ethtool.

One of the sticking points in earlier discussions was how to handle
devices that have limited support for slave devices. When we create a
netdev we expect the stack can bind to it and TX/RX packets which as
I understand is not always possible? (I missed why we couldn't recv the
packets over a switch port though with some skb->dev manipulation). In
this case a feature flag could be used to resolve the feature
dependencies.

.John


-- 
John Fastabend         Intel Corporation
