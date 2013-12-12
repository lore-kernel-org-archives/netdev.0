From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH 0/2] Display adjacent switch port's attributes
Date: Thu, 12 Dec 2013 09:52:13 -0800
Message-ID: <52A9F7CD.5050904@intel.com>
References: <1386768540-48188-1-git-send-email-raspl@linux.vnet.ibm.com> <20131211121357.4742d9e8@nehalam.linuxnetplumber.net> <52A9C0BE.5090801@linux.vnet.ibm.com> <20131212.122801.1249371766101769652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	bhutchings@solarflare.com, blaschka@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: raspl@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:11785 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751884Ab3LLRwX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Dec 2013 12:52:23 -0500
In-Reply-To: <20131212.122801.1249371766101769652.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/12/2013 9:28 AM, David Miller wrote:
> From: Stefan Raspl <raspl@linux.vnet.ibm.com>
> Date: Thu, 12 Dec 2013 14:57:18 +0100
>
>> I agree, netlink would certainly be nice. But ethtool is the
>> de-facto standard for now, and there doesn't seem to be a
>> netlink-based alternative in sight - or is there?
>> Offering a netlink based tool seems to be a different discussion,
>> and if that takes shape, existing ethtool functionality (including
>> this series) can and should be migrated.
>
> I completely disagree, ethtool is not de-facto for anything in
> particular.  It's suitable for some things, not suitable for
> others.
>
> And just because it's used for other aspects of a device's
> configuration doesn't mean that netlink isn't appropriate for other
> apsects.

Just to elaborate...

Any application using lldp information will want to get events when
TLVs change. Maybe you can contrive ethtool to do this but its going to
be ugly. Netlink can support multicast events and applications can
register for them. Also netlink's TLV format matches nicely with LLDPs
TLV format.

If you push an ethtool interface now we get stuck with an interface
that is only useful in a very narrow use case. And netlink interfaces
are relatively easy to construct so lets do this right the first time.
I also happen to maintain lldpad and would be happy to plug in support
for this via netlink so we can push firmware and software based agent
LLDP info up to libvirt/network manager whatever in a consistent way.
Similarly other existing lldp agents could do the same.

Thanks,
.John
