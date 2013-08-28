From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v10 07/11] vxlan: add ipv6 route short circuit
 support
Date: Wed, 28 Aug 2013 09:08:01 -0700
Message-ID: <20130828090801.64a89878@nehalam.linuxnetplumber.net>
References: <1377667379-2315-1-git-send-email-amwang@redhat.com>
	<1377667379-2315-8-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	David Stevens <dlstevens@us.ibm.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:61291 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754067Ab3H1QIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 12:08:05 -0400
Received: by mail-pd0-f174.google.com with SMTP id y13so6427980pdi.5
        for <netdev@vger.kernel.org>; Wed, 28 Aug 2013 09:08:05 -0700 (PDT)
In-Reply-To: <1377667379-2315-8-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Aug 2013 13:22:55 +0800
Cong Wang <amwang@redhat.com> wrote:

> +		n = neigh_lookup(ipv6_stub->nd_tbl, &pip6->daddr, dev);
> +		if (!n && vxlan->flags & VXLAN_F_L3MISS) {
> +			union vxlan_addr ipa;
> +			ipa.sin6.sin6_addr = pip6->daddr;
> +			ipa.sa.sa_family = AF_INET6;

Please always add paren's when doing bitwise mask in comparison, gcc will even warn
about this.

You could use C99 initialization for this which has added benefit
of zeroing unused fields.
			union vxlan_addr ipa = {
				.sa.sa_family = AF_INET6,
				.sin6.sin6_sin6)addr = pip6->daddr,
			};
