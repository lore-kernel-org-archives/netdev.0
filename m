From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [net-next,1/3] bonding: fix vlan 0 addition and removal
Date: Tue, 06 Aug 2013 11:01:31 +0200
Message-ID: <5200BB6B.3080707@redhat.com>
References: <1375709304-16778-2-git-send-email-nikolay@redhat.com> <20130805215126.GB3859@redhat.com> <5200B0C4.2020101@redhat.com> <20130806085111.GL22756@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, kaber@trash.net
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2021 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755287Ab3HFJBu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 05:01:50 -0400
In-Reply-To: <20130806085111.GL22756@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2013 10:51 AM, Veaceslav Falico wrote:
> On Tue, Aug 06, 2013 at 10:16:04AM +0200, Nikolay Aleksandrov wrote:
>> On 08/05/2013 11:51 PM, Veaceslav Falico wrote:
>>> On Mon, Aug 05, 2013 at 03:28:22PM +0200, nikolay@redhat.com wrote:
>>> ...snip...
>>>> This is fixed by forbidding the addition/removal of vlan 0 through the
>>>> bond's ndo_vlan_rx_add/kill_vid functions, and adding/removing it only
>>>> when
>>>> vlan 0 is in fact being created (or destroyed) on top of a bond interface
>>>> in the bond's netdev handling function.
>>>
>>> Isn't that a bit too intrusive/hacky? I don't think we should treat vlan id
>>> 0 somehow differently in terms of adding/removing, though I might be
>>> wrong...
>>>
>> I didn't want to touch the vlan code, so I solved the problem entirely in
>> the bonding, mind you there's still a bug when loading the 8021q module
>> we'll bump up every slave's vlan 0 refcnt without adding the vlan, and it
>> won't get bumped down.
>> In my patch that problem still persists but only when an actual vlan 0 is
>> being created.
> 
> I'll look into that, though maybe we'll require another patch to fix it.
> 
You can take a look at:
http://www.spinics.net/lists/netdev/msg241858.html#.UgC5rxoW2Y4
and
http://www.spinics.net/lists/netdev/msg241999.html#.UgC5_BoW2Y4

I think I've explained the refcnt bug well there.


Thanks,
 Nik
