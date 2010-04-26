From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next-2.6 PATCH 1/2] Add ndo_set_vf_port_profile
Date: Mon, 26 Apr 2010 12:27:51 -0700
Message-ID: <C7FB3747.2BAAA%scofeldm@cisco.com>
References: <20100424.001934.189691704.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <chrisw@redhat.com>, <arnd@arndb.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:56408 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753347Ab0DZT2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 15:28:25 -0400
In-Reply-To: <20100424.001934.189691704.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/24/10 12:19 AM, "David Miller" <davem@davemloft.net> wrote:

>> int   (*ndo_set_vf_tx_rate)(struct net_device *dev,
>>      int vf, int rate);
>> + int   (*ndo_set_vf_port_profile)(
>> +     struct net_device *dev, int vf,
>> +     u8 *port_profile, u8 *mac,
>> +     u8 *host_uuid,
>> +     u8 *client_uuid,
>> +     u8 *client_name);
>> int   (*ndo_get_vf_config)(struct net_device *dev,
> 
> Just pass the "struct ifla_vf_port_profile *" instead of tons of
> arguments.

Ok
 
> Also, I think it's reasonable to fetch the current profile in use, so
> GETLINK ought to report these things.  To make it generic we can
> maintain the settings given to us in software, hung off of the netdev
> struct, and simply report that during GETLINK.

We'd need an array of struct ifla_vf_port_profile hanging off of netdev, one
element for each VF.  That seems like a lot of mem hanging off of netdev,
and we'd have to define a MAX_VF to size the array.  How about a
ndo_get_vf_port_profile() that the netdev fills in, and the netdev keeps the
data in it's private area?  That's how ndo_get_vf_config() is working.
 
-scott

