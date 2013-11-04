From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH RESEND] packet: Deliver VLAN TPID to userspace
Date: Mon, 4 Nov 2013 17:16:31 +0000
Message-ID: <1383585391.1553.7.camel@bwh-desktop.uk.level5networks.com>
References: <87r4bdk8c3.wl%atzm@stratosphere.co.jp>
	 <20131025.185920.1893524127229371162.davem@davemloft.net>
	 <1382991074.3779.22.camel@bwh-desktop.uk.level5networks.com>
	 <878uxbjl4n.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<stephen@networkplumber.org>
To: Atzm Watanabe <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:37277 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752661Ab3KDRQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 12:16:35 -0500
In-Reply-To: <878uxbjl4n.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-30 at 16:03 +0900, Atzm Watanabe wrote:
[...]
> Should it be structures as below?
>
> struct tpacket_hdr_variant1 {
>         __u32   tp_rxhash;
>         __u32   tp_vlan_tci;
> };
> 
> struct tpacket_hdr_variant2 {
>         __u32   tp_rxhash;
>         __u32   tp_vlan_tci;
>         __u32   tp_vlan_tpid;
> };
> 
> struct tpacket3_hdr {
>         __u32           tp_next_offset;
>         __u32           tp_sec;
>         __u32           tp_nsec;
>         __u32           tp_snaplen;
>         __u32           tp_len;
>         __u32           tp_status;
>         __u16           tp_mac;
>         __u16           tp_net;
>         /* pkt_hdr variants */
>         union {
>                 struct tpacket_hdr_variant1 hv1;
>                 struct tpacket_hdr_variant2 hv2;
>         };
> };
> 
> If it's ok, I'd like to send the patch v2.
[...]

I think this makes sense.

Also add a BUILD_BUG_ON(TPACKET3_HDRLEN != 48) somewhere.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
