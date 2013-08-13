From: Krisztian Ivancso <github-ivan@ivancso.net>
Subject: Re: [PATCH net-next] bonding: lacp_port_id setting for 802.3ad
Date: Tue, 13 Aug 2013 13:00:29 +0200
Message-ID: <520A11CD.8060400@ivancso.net>
References: <5208C4BA.9020605@ivancso.net> <520986DC.4030805@huawei.com> <5209FA49.6030800@ivancso.net> <5209FEBC.4050305@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhandler.info ([217.116.47.195]:33500 "EHLO mailhandler.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757352Ab3HMLAb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Aug 2013 07:00:31 -0400
In-Reply-To: <5209FEBC.4050305@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/13/2013 11:39 AM, Ding Tianhong wrote:
> On 2013/8/13 17:20, Krisztian Ivancso wrote:
>> On 08/13/2013 03:07 AM, Ding Tianhong wrote:
>>> On 2013/8/12 19:19, Krisztian Ivancso wrote:
>>>> >From 472fffa5a8f170daed9e4cc677af8e2560b86be2 Mon Sep 17 00:00:00 2001
>>>> From: Krisztian Ivancso <github-ivan@ivancso.net>
>>>> Date: Sun, 11 Aug 2013 20:30:44 +0200
>>>> Subject: [PATCH net-next] bonding: lacp_port_id setting for 802.3ad ports
> 
> ok, for example: the bonding has four slave, slave1 and slave2 aggregation to 1 group,
> and slave3 and slave4 aggregtion to 2 group, how you distinguish the 1 and 2 group by initialize id.

this is not possible, because all slave have to be a member of the same
aggregation group.

i think we misunderstood each other.

here is a new example:
- switch1 is a switch with a configured lag with two members ports
  (member1 and member2)
- two linux (linux1 and linux2) box with a configured bonding device
  (bond0) with the same MAC set in both box and one
  slave on each
- lacp_port_id is set to 10 in linux1 and 20 in linux2

you can attach the slave from both linux boxes to the same
lag on switch1. (slave from linux1 to port member1 and
slave from linux2 to port member2 on switch1)

port id must be unique within a system.
bonding implementation set a unique system id for every bonding device
which is derived from MAC of one of the slave interfaces.

if we use the current bonding implementation second linux box can't be
a member on switch1 because port id is 1 in both linux bonding device.

if we can set different starting port id for bonding in different boxes
the second box can be a member also.
