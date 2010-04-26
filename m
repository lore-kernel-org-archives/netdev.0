From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next-2.6 PATCH 1/2] Add ndo_set_vf_port_profile
Date: Mon, 26 Apr 2010 16:21:47 -0700
Message-ID: <C7FB6E1B.2BC18%scofeldm@cisco.com>
References: <43F901BD926A4E43B106BF17856F0755A3BE8B8F@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"chrisw@redhat.com" <chrisw@redhat.com>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:7404 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622Ab0DZXVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 19:21:50 -0400
In-Reply-To: <43F901BD926A4E43B106BF17856F0755A3BE8B8F@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/26/10 3:38 PM, "Rose, Gregory V" <gregory.v.rose@intel.com> wrote:

>> On 4/26/10 12:27 PM, "Scott Feldman" <scofeldm@cisco.com> wrote:
>> Here's a proposal:
>> 
>> Currently we have RTM_GETLINK for
>> 
>>    ip link show [ DEVICE ]
>> 
>> This dumps everything for the DEVICE including info for each VF.  Let's
>> modify RTM_GETLINK to look like this:
>> 
>>    ip link show [ DEVICE [ vf NUM] ]
>> 
>> If you don't give the optional vf NUM you get base dump on DEVICE.  If
>> you
>> give vf NUM, you get the VF-specific dump.  This scales much better with
>> the
>> number of VFs.
>> 
>> (Number of VFs can easily be > 128 in some designs).
>> 
>> Comments?
> 
> It seems to me that this:
> 
> ip link show [ DEVICE ]
> 
> should at least return the number of VFs so
> that you can make sure the subsequent usage of this:

Yes, I believe that's there today:

    NLA_PUT_U32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent));

The number of VFs is returned in RTM_GETLINK.  But, it's only returned if:

    if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent)

For my proposal, I'll need to return IFLA_NUM_VF unconditionally so callers
can get num VFs.
 
> ip link show [ DEVICE [ vf NUM ] ]
> 
> is still in range with the [ vf NUM ] parameter.  Otherwise you wouldn't know
> what the range of NUM is.
> 
> Other than that I can see why you would want to limit the size of the dump
> when using 'ip link show [ DEVICE ]'.
> 
> - Greg
> 

