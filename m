From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v3 07/13] bonding: make bond_arp_send_all use
 upper device list
Date: Wed, 28 Aug 2013 20:11:01 +0200
Message-ID: <20130828181101.GA13390@redhat.com>
References: <1377705842-8276-1-git-send-email-vfalico@redhat.com>
 <1377705842-8276-8-git-send-email-vfalico@redhat.com>
 <521E2932.6060307@redhat.com>
 <20130828172335.GM1992@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12110 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753746Ab3H1SMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 14:12:18 -0400
Content-Disposition: inline
In-Reply-To: <20130828172335.GM1992@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 28, 2013 at 07:23:35PM +0200, Veaceslav Falico wrote:
>On Wed, Aug 28, 2013 at 12:45:38PM -0400, Vlad Yasevich wrote:
>>On 08/28/2013 12:03 PM, Veaceslav Falico wrote:
>...snip...
>>>+		/* search for upper device, like vlan/bridge/team/etc */
>>>+		rcu_read_lock();
>>>+		netdev_for_each_upper_dev_rcu(bond->dev, upper, iter) {
>>>+			if (upper == rt->dst.dev) {
>>>+				/* if it's a vlan - get its VID */
>>>+				if (is_vlan_dev(rt->dst.dev))
>>>+					vlan_id = vlan_dev_vlan_id(rt->dst.dev);
>>>+
>>>+				rcu_read_unlock();
>>>+				goto found;
>>>+			}
>>
>>How does this work in the following config:
>>	eth0,eth1 <--- bond <--- vlans 1,2,3 <---- bridge (ip address)
>
>Great catch, it won't work. I'm not sure if the old code does work (cause
>bond->dev already has vlans on top of it, so it has the ->vlan_info, and
>thus __vlan_find_dev_deep() won't go recursive, but rather check the
>bond->dev for the ip address, though I might be wrong), but I'll try to
>take a look at the new code to make it work.
>
>First what comes to mind (untested, not compiled):

(sorry for the spam - I've sent the mail from android and because it still
can't send anything but html email it bounced from netdev list)

actually, we should just go through the upper list
twice - first looking at all upper vlan's master devices
via __vlan_find_dev_deep(), and if found - get the tag,
and then loop through all devices.

i'll test it and send the next version, if nothing else
comes up.

thanks for the catch and the review.
