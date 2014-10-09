From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFT 0/8] Marvell PXA168 libphy handling and Berlin Ethernet
Date: Thu, 09 Oct 2014 09:57:35 -0700
Message-ID: <5436BE7F.7000603@gmail.com>
References: <1412858346-11334-1-git-send-email-sebastian.hesselbarth@gmail.com> <20141009163315.2a9e1806@free-electrons.com> <54369EAC.5040301@gmail.com> <20141009164704.7286fc3f@free-electrons.com> <5436A8B2.1030200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, Eric Miao <eric.y.miao@gmail.com>,
	netdev@vger.kernel.org,
	=?UTF-8?B?QW50b2luZSBUw6luYXJ0?=
	<antoine.tenart@free-electrons.com>, linux-kernel@vger.kernel.org,
	Haojian Zhuang <haojian.zhuang@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:48467 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855AbaJIQ5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 12:57:45 -0400
In-Reply-To: <5436A8B2.1030200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/2014 08:24 AM, Sebastian Hesselbarth wrote:
> On 10/09/2014 04:47 PM, Thomas Petazzoni wrote:
>> Well, I initially remember that the original driver coming from Marvell
>> was using the HW PHY stuff, and that I changed that because it would
>> not integrate well with the kernel libphy.
>>
>> A drawback of this is that because the hardware has built-in PHY
>> polling which triggers a MAC interrupt when the PHY status changes, they
>> typically don't wire up the PHY interrupt. Therefore, since we're not
>> able to use the MAC interrupt for PHY event notifications, we rely on
>> software PHY polling, which means that link up / link down events take
>> a few seconds to be noticed by the kernel. Unfortunately, I don't think
>> the hardware allows to use the hardware PHY polling to get link changes
>> interrupt, but not let the hardware configure the PHY itself.
> 
> Yeah, but that HW PHY stuff really only works properly with standard
> compliant PHYs. In particular, the integrated Marvell PHY in Marvell
> Berlin SoCs does not seem to reflect PHY status on BMCR properly /sigh/.
> Anyway, I think we can live with PHY polling.
> 
> BTW, one thing I noticed here is that libphy calls adjust_link
> over-and-over again although nothing has changed. I guess we can just
> add some before/after comparison in the libphy state machine and only
> call adjust_link when something has changed. I'll have to look closer
> at the state machine first and maybe Florian can comment on this,
> too.

There's basically nothing built in the generic libphy that would try to
limit the number of times the adjust_link() callback is invoked, some
changes went in the bcmgenet driver to avoid that, I have yet to see how
much of this logic is transferable to the libphy layer.
--
Florian
