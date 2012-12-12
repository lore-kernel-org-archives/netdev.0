From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 00/11] Add basic VLAN support to bridges
Date: Wed, 12 Dec 2012 15:12:17 -0500
Message-ID: <50C8E521.9090900@redhat.com>
References: <1355342477-4971-1-git-send-email-vyasevic@redhat.com> <20121212120541.72ba1ba9@nehalam.linuxnetplumber.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, mst@redhat.com,
	john.r.fastabend@intel.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1120 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755149Ab2LLUMU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 15:12:20 -0500
In-Reply-To: <20121212120541.72ba1ba9@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/12/2012 03:05 PM, Stephen Hemminger wrote:
> On Wed, 12 Dec 2012 15:01:06 -0500
> Vlad Yasevich <vyasevic@redhat.com> wrote:
>
>> This series of patches provides an ability to add VLANs to the bridge
>> ports.  This is similar to what can be found in most switches.  The bridge
>> port may have any number of VLANs added to it including vlan 0 priority tagged
>> traffic.  When vlans are added to the port, only traffic tagged with particular
>> vlan will forwarded over this port.  Additionally, vlan ids are added to FDB
>> entries and become part of the lookup.  This way we correctly identify the FDB
>> entry.
>>
>> A single vlan may also be designated as untagged.  Any untagged traffic
>> recieved by the port will be assigned to this vlan.  Any traffic exiting
>> the port with a VID matching the untagged vlan will exit untagged (the
>> bridge will strip the vlan header).  This is similar to "Native Vlan" support
>> available in most switches.
>>
>> The default behavior ofthe bridge is unchanged if no vlans have been
>> configured.
>
> My concern is that all older configurations must continue to work.
> Is it still unchanged if a vlan device is added to the bridge, or vlan is
> configured on an ethernet that has been added to the bridge?
>

Yes. I've tested with vlans under the bridge and on top of the bridge. 
This code doesn't have any effect if the no filtering is configured.
I am finishing changes to iproute to do the configuration.

-vlad
