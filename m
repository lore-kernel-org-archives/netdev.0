From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next v5 02/14] bridge: Add vlan filtering infrastructure
Date: Thu, 10 Jan 2013 20:14:01 -0500
Message-ID: <50EF6759.2000908@redhat.com>
References: <1357751882-8619-1-git-send-email-vyasevic@redhat.com> <1357751882-8619-3-git-send-email-vyasevic@redhat.com> <20130110103614.23383079@nehalam.linuxnetplumber.net> <50EF0FF7.3080407@redhat.com> <50EF1537.7030209@redhat.com> <20130110141005.427ccaf9@nehalam.linuxnetplumber.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, stephen@redhat.com,
	bridge@lists.linux-foundation.org, shmulik.ladkani@gmail.com,
	mst@redhat.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3099 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752841Ab3AKBOF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 20:14:05 -0500
In-Reply-To: <20130110141005.427ccaf9@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2013 05:10 PM, Stephen Hemminger wrote:
> The problem with your approach is that it
> adds a hash lookup in the packet process critical path.
>

Right now it is a list lookup and only happens if there is
VLAN filtering configured.  Shmulik argued that hash lookup would
be faster, and that would be true for large number of vlans.  List
works better for smaller number of vlans.

Something to keep in mind is that this only happens if a port has a
vlan configuration.  Out of the box, the cost is that of a
	if (list_empty())
statement.

> Also the concept of different filters for egress vs ingress is feature
> madness. It doesn't make sense to have half-duplex connectivity.
>

I am of the same opinion, but it actually simplified the code quite a 
bit, but at the cost of additional memory footprint.  If you find this
very objectionable, I can easily remove it.

Thanks
-vlad
