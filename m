From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC PATCH bridge 0/5] Add basic VLAN support to bridges
Date: Thu, 23 Aug 2012 15:53:59 -0400
Message-ID: <50368A57.3050801@redhat.com>
References: <1345750195-31598-1-git-send-email-vyasevic@redhat.com> <20120823124141.402b7b34@nehalam.linuxnetplumber.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45243 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758191Ab2HWTyB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 15:54:01 -0400
In-Reply-To: <20120823124141.402b7b34@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2012 03:41 PM, Stephen Hemminger wrote:
> On Thu, 23 Aug 2012 15:29:50 -0400
> Vlad Yasevich <vyasevic@redhat.com> wrote:
>
>> This series of patches provides an ability to add VLAN IDs to the bridge
>> ports.  This is similar to what can be found in most switches.  The bridge
>> port may have any number of VLANs added to it including vlan 0 for untagged
>> traffic.  When vlans are added to the port, only traffic tagged with particular
>> vlan will forwarded over this port.  Additionally, vlan ids are added to FDB
>> entries and become part of the lookup.  This way we correctly identify the FDB
>> entry.
>>
>> There are still pieces missing.  I don't yet support adding a static fdb entry
>> with a particular vlan.  There is no netlink support for carrying a vlan id.
>>
>> I'd like to hear thoughts of whether this is usufull and something we should
>> persue.
>>
>> The default behavior ofthe bridge is unchanged if no vlans have been
>> configured.
>
> Initial reaction is that this is a useful. You can already do the same thing
> with ebtables, and ebtables allows more flexibility. But ebtables does slow
> things down, and is harder to configure.

Slowness of ebtables is exactly why I thought of doing this.  This code 
works pretty well when you have guests running on different vlans.  It 
makes sure that there is no traffic leakage.

I'll write up the netlink pieces and repost.

Thanks
-vlad
