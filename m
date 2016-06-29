From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v2 iproute2 0/6] Add support for vrf keyword
Date: Wed, 29 Jun 2016 11:06:13 -0600
Message-ID: <15470508-47f3-ce7e-420a-085ab6131127@cumulusnetworks.com>
References: <1467053461-16147-1-git-send-email-dsa@cumulusnetworks.com>
 <20160629080740.198843fe@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36126 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751230AbcF2RGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 13:06:12 -0400
Received: by mail-pa0-f43.google.com with SMTP id wo6so19265492pac.3
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 10:06:12 -0700 (PDT)
In-Reply-To: <20160629080740.198843fe@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/29/16 9:07 AM, Stephen Hemminger wrote:
> On Mon, 27 Jun 2016 11:50:55 -0700
> David Ahern <dsa@cumulusnetworks.com> wrote:
>
>> Currently the syntax for VRF related commands is rather kludgy and
>> inconsistent from one subcommand to another. This set adds support
>> for the VRF keyword to the link, address, neigh, and route commands
>> to improve the user experience listing data associated with vrfs,
>> modifying routes or doing a route lookup.
>>
>> v2
>> - rebased to top of tree
>> - all checkpatch warnings are usage lines. The change in these
>>   patches is consistent with existing code for usage lines
>
> Does this break current user scripts?

I don't see how it can. Existing syntax is not touched so if a user 
wants to run:

$ ip link show master red
$ ip ro sh table 1001

it still works. Using the vrf keyword just makes for a more natural syntax:

$ ip link show vrf red
$ ip ro sh vrf red

in this case I don't have to lookup what table device red is associated 
with ip learns it and shows that table.

>
> It seems this method will cause lots of additional netlink requests
> to check if device is a vrf. Won't this impact users with 1000's of devices?
>

It only adds 1 GETLINK request if the vrf keyword is used. The lookup 
verifies the name is actually a VRF. It's really no different than the 
ll_name_to_index lookups used when processing the command line 
(ll_name_to_index relies on a cache or an ioctl, if_nametoindex).
