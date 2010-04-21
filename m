From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next,1/2] add iovnl netlink support
Date: Wed, 21 Apr 2010 13:25:35 -0700
Message-ID: <C7F4AD4F.2A34D%scofeldm@cisco.com>
References: <201004212139.22421.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>, Chris Wright <chrisw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:39111 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756389Ab0DUU0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 16:26:23 -0400
In-Reply-To: <201004212139.22421.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/21/10 12:39 PM, "Arnd Bergmann" <arnd@arndb.de> wrote:

>>> 1. Setting up the slave device
>>>  a) create an SR-IOV VF to assign to a guest
>>>  b) create a macvtap device to pass to qemu or vhost
>>>  c) attach a tap device to a bridge
>>>  d) create a macvlan device and put it into a container
>>>  e) create a virtual interface for a VMDq adapter
>> 
>> OK, but iovnl isn't doing this.
> 
> The set_mac_vlan that Scott's patch adds seems to implement 1a), as far
> as I can tell. Interestingly, this is not actually implemented in
> the enic driver in patch 2/2. So if we all agree that this is out of the
> scope of iovnl, let's just remove it from the interface and find another
> way for it (ethtool, iplink, ..., as listed above).

You're right, not needed for enic since mac addr is included with
port-profile push and vlan membership is implied by port-profile.  So I put
set_mac_vlan in there basically to elicit feedback.

There really wouldn't be much different between iplink and iovnl since
they're both rtnetlink...seems we should keep IOV-related APIs in one place.
Maybe there are other IOV APIs to add to iovnl in the future like:

    vf <- add_vf(pf)
    del_vf(pf, vf)

Ethtool doesn't seem the right place for this.

-scott

