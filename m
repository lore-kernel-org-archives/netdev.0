From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] rocker: add debugfs support to dump
 internal tables
Date: Tue, 18 Aug 2015 13:47:20 -0700 (PDT)
Message-ID: <20150818.134720.1520233036019988872.davem@davemloft.net>
References: <CAE4R7bAwuZkoOqO1eA9pWQ35UPiSs7-Fm+AaedVU1wwiRZ=Jwg@mail.gmail.com>
	<20150818181930.GK4381@lunn.ch>
	<CAE4R7bA621-ySQuOJ_kLTSju7ZwD3Ur4oSAS0JCE4EjzEsRr7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, jiri@resnulli.us
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42255 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165AbbHRUrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 16:47:22 -0400
In-Reply-To: <CAE4R7bA621-ySQuOJ_kLTSju7ZwD3Ur4oSAS0JCE4EjzEsRr7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>
Date: Tue, 18 Aug 2015 13:37:56 -0700

> On Tue, Aug 18, 2015 at 11:19 AM, Andrew Lunn <andrew@lunn.ch> wrote:
>> On Tue, Aug 18, 2015 at 10:18:51AM -0700, Scott Feldman wrote:
>>> On Tue, Aug 18, 2015 at 7:01 AM, Andrew Lunn <andrew@lunn.ch> wrote:
>>> > On Mon, Aug 17, 2015 at 03:36:17PM -0700, sfeldma@gmail.com wrote:
>>> >> From: Scott Feldman <sfeldma@gmail.com>
>>> >>
>>> >> > tree /sys/kernel/debug/rocker
>>> >> /sys/kernel/debug/rocker
>>> >> ????????? 5254001235010000
>>> >>     ????????? fdb_tbl
>>> >>     ????????? internal_vlan_tbl
>>> >>     ????????? neigh_tbl
>>> >>     ????????? of_dpa_flow_tbl
>>> >>     ????????? of_dpa_group_tbl
>>> >>
>>> >> 1 directory, 5 files
>>> >>
>>> >> > cat /sys/kernel/debug/rocker/5254001235010000/internal_vlan_tbl
>>> >> ifindex 5 ref_count 1 vlan 3843
>>> >> ifindex 7 ref_count 2 vlan 3840
>>> >> ifindex 4 ref_count 1 vlan 3842
>>> >>
>>> >> > cat /sys/kernel/debug/rocker/5254001235010000/fdb_tbl
>>> >> learned 1 pport 1 addr 00:02:00:00:02:00 vlan 3840
>>> >> learned 1 pport 2 addr 00:02:00:00:03:00 vlan 3840
>>> >>
>>> >> > cat /sys/kernel/debug/rocker/5254001235010000/neigh_tbl
>>> >> 11.0.0.9 dev sw1p2 ref_count 3 index 1 dst 00:02:00:00:01:00 ttl_check 1
>>> >> 11.0.0.1 dev sw1p1 ref_count 3 index 0 dst 00:02:00:00:00:00 ttl_check 1
>>> >
>>> > Hi Scott
>>> >
>>> > David is not so keen no debugfs stuff. He already NACKed adding more
>>> > than what is currently in DSA:
>>> >
>>> > https://lkml.org/lkml/2015/7/11/8
>>>
>>> That patch added writable debugfs files, which I can see might be used
>>> as a back-door to program hardware.  That does seem bad.
>>
>> I fully agreed with respect to write. But if you read the whole
>> message, David is also not happy with read only.
>>
>> I think before you spend too much more time on this, you need some
>> indication from David if he is going to merge it or not.
> 
> David, please give us guidance on debugfs in drivers/net.  Is there
> some criteria we can define to know when it's OK to use debugfs?

The less you use it the better, seriously.

I see some drivers where the foo_debugfs.c file is larger than the rest
of the driver.  Once people start using it, it's like crack, and they
dump every single debugging widget they found useful at some point into
there.

This is not what we want.  Most things I see in debugfs support was
probably useful for debugging one particular bug but then it was never
really useful again in the future.  Those kinds of things can be done
locally in someone's tree.

I often see various kinds of "statistics" ending up in these things,
or register dumps, both of which are 'ethtool' or similar material.
