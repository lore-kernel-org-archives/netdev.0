From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: MLD maturity in kernel version 2.6.32.60
Date: Thu, 21 Nov 2013 05:04:16 +0100
Message-ID: <20131121040416.GA4347@order.stressinduktion.org>
References: <trinity-825e48d2-0bab-4020-84f0-77800e55f25a-1384777048114@3capp-gmx-bs16> <20131118221850.GO16541@order.stressinduktion.org> <528AACF4.1090302@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Simon Schneider <simon-schneider@gmx.net>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56210 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501Ab3KUEET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 23:04:19 -0500
Content-Disposition: inline
In-Reply-To: <528AACF4.1090302@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 19, 2013 at 01:12:36AM +0100, Daniel Borkmann wrote:
> There's also still one issue which I am hesitant to implement, as i) I don't
> think it's overly useful, ii) nobody complained so far. :-)
> 
> In RFC2710 (MLD v1 spec), it says:
> 
> 3.7. Other fields
> 
>    The length of a received MLD message is computed by taking the IPv6
>    Payload Length value and subtracting the length of any IPv6 extension
>    headers present between the IPv6 header and the MLD message.  If that
>    length is greater than 24 octets, that indicates that there are other
>    fields present beyond the fields described above, perhaps belonging
>    to a future backwards-compatible version of MLD.  An implementation
>    of the version of MLD specified in this document MUST NOT send an MLD
>    message longer than 24 octets and MUST ignore anything past the first
>    24 octets of a received MLD message.  In all cases, the MLD checksum
>    MUST be computed over the entire MLD message, not just the first 24
>    octets.
> 
> Then, RFC3810 which "updates" RFC2710 obviously has a bigger message length
> than that. In igmp6_event_query(), we only check for len == MLD_V1_QUERY_LEN
> and process MLD v1. Now, in case of MLD v1-only fallback, we MUST only
> operate in v1 mode.
> 
> Now, in case a v2 message comes in we could assume above statement "if
> that length is greater than 24 octets, that indicates that there are other
> fields present beyond the fields described above, perhaps belonging to a
> future backwards-compatible version of MLD".
> 
> But then on the other hand, we get completely wrong "Maximum Response Delay"
> codes in the packet header as they are differently encoded in MLD v1 and MLD
> v2 thus not really backwards compatible.

Daniel, let's add something where we can easier export the per-interface
mld status for net-next inclusive the timers either via netlink or procfs.

I guess we cannot change /proc/net/igmp6 because of backward compatibility
so I favor to add this via Nicolas netconf api.
