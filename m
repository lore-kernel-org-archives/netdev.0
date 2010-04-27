From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next-2.6 PATCH 1/2] Add ndo_set_vf_port_profile
Date: Mon, 26 Apr 2010 17:03:23 -0700
Message-ID: <C7FB77DB.2BC42%scofeldm@cisco.com>
References: <C7FB6E1B.2BC18%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"chrisw@redhat.com" <chrisw@redhat.com>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
To: Scott Feldman <scofeldm@cisco.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:33608 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046Ab0D0ADY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 20:03:24 -0400
In-Reply-To: <C7FB6E1B.2BC18%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/26/10 4:21 PM, "Scott Feldman" <scofeldm@cisco.com> wrote:

>> It seems to me that this:
>> 
>> ip link show [ DEVICE ]
>> 
>> should at least return the number of VFs so
>> that you can make sure the subsequent usage of this:
> 
> Yes, I believe that's there today:
> 
>     NLA_PUT_U32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent));
> 
> The number of VFs is returned in RTM_GETLINK.  But, it's only returned if:
> 
>     if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent)
> 
> For my proposal, I'll need to return IFLA_NUM_VF unconditionally so callers
> can get num VFs.

Hmmm...seems IFLA_NUM_VF assumes a PCI device supporting SR-IOV when it uses
dev_num_vf().  I think a better option would have been to query the device
for the number of VFs, without assuming SR-IOV or even PCI.

I see a ndo_get_num_vf() coming...

-scott

