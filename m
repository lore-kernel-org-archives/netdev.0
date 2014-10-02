From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Subject: Re: [PATCH net-next 2/2] sunvnet: vnet_start_xmit() must hold a refcnt on port.
Date: Wed, 1 Oct 2014 20:36:38 -0700
Message-ID: <3DC66499-B569-4EB6-AB9B-D0F6415BAB78@oracle.com>
References: <542C50A4.30304@oracle.com> <20141001192325.GK17706@oracle.com> <542C56A5.4070805@oracle.com> <20141001.155210.882272719949254470.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: david.stevens@oracle.com, sowmini.varadhan@oracle.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41143 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182AbaJBDgq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 23:36:46 -0400
In-Reply-To: <20141001.155210.882272719949254470.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Oct 1, 2014, at 12:52 PM, David Miller <davem@davemloft.net> wrote:

> From: David L Stevens <david.stevens@oracle.com>
> Date: Wed, 01 Oct 2014 15:31:49 -0400
> 
>> 
>> 
>> On 10/01/2014 03:23 PM, Sowmini Varadhan wrote:
>>> On (10/01/14 15:06), David L Stevens wrote:
>>>> 
>>>> This "vp->switch_port" addition doesn't appear to be related to the port refcnt
>>>> change, and doesn't allow for multiple switch ports.
>>> 
>>> The switch_port is the connection to Dom0. Do you envision us having more than
>>> one switch_port? How?
>> 
>> While Dom0 might only create one port with the "switch" flag, the flag just means
>> "I can reach anybody" and is not inherently unique. I don't think an attached
>> VM should assume there is always only one; it prevents multipath load balancing
>> kinds of things in the future.
>> 
>> Also, there is the broader point that this sort of change should be a separate patch.
>> It isn't required for fixing the dangling reference -- it is an independent change.
> 
> Multiple switch ports are absolutely allowed by the protocol spec and can
> provide the suggested facilities David mentioned, don't prevent them from
> being used.

In reality, introducing multiple switch-ports will need Guest driver change
as well. The existing sunvnet driver will not automatically utilize all switch-ports
and requires changes. When we add the full support to use multiple switch-ports,
I am sure we can change the current optimization for switch-port lookup with
a different method probably with another optimized method than what it is today.

-Raghuram