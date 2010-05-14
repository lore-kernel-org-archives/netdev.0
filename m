From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next-2.6 V7 PATCH 1/2] Add netlink support for virtual port
 management (was iovnl)
Date: Fri, 14 May 2010 10:19:00 -0700
Message-ID: <C812D414.3180C%scofeldm@cisco.com>
References: <4BED7D64.3070500@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<chrisw@redhat.com>
To: Patrick McHardy <kaber@trash.net>, Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:34784 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755069Ab0ENRTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 13:19:04 -0400
In-Reply-To: <4BED7D64.3070500@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/14/10 9:42 AM, "Patrick McHardy" <kaber@trash.net> wrote:

> Arnd Bergmann wrote:
>> Maybe a better structure would be to separate the two cases, also allowing
>> a port profile to be associated with both the PF and with each of its VFs?
>> 
>> Something like this:
>> 
>> [IFLA_NUM_VF]
>> [IFLA_VF_PORTS]
>>   [IFLA_VF_PORT]
>>     [IFLA_VF_PORT_*], ...
>>   [IFLA_VF_PORT]
>>     [IFLA_VF_PORT_*], ...
>> [IFLA_PORT_SELF]
>>   [IFLA_VF_PORT_*], ...
> 
> That would also be fine.

I want to make sure I've got this right before starting on ver8 of patch:

    - we'll use the layout listed above

    - RTM_SETLINK msg includes the full nested layout

        - contains IFLA_VF_PORTs for all VFs of a PF
        - OR, contains IFLA_PORT_SELF if PF is it's own VF

        - it's up to the receiver to compare for changes for each VF

    - RTM_GETLINK msg includes the full nested layout

        - same rules as RTM_SETLINK above

I think we should redo the other IFLA_VF_xxx msgs in the same style.  I'm
not going to tackle that for IFLA_VF_PORTS patch, but it would be a good
followup patch.

Do we have a plan?

-scott

