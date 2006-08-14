From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH] d80211: get rid of the WME bitfield
Date: Mon, 14 Aug 2006 09:12:10 -0700
Message-ID: <20060814161210.GD1196@instant802.com>
References: <44E02F41.2060300@sipsolutions.net> <44E03112.9070002@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-39.dex002.intermedia.net ([64.78.21.124]:4208 "EHLO
	dhost002-39.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751485AbWHNQQ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 12:16:27 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <44E03112.9070002@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 14, 2006 at 10:15:14AM +0200, Johannes Berg wrote:
> Somewhere, sometime, someone had to start getting rid of bitfields ;) 

Yes and you wouldn't believe how many times I have had to complain about
this particular case internally with it always coming back as bitfield
even after showing that it caused a unaligned access on one target
platform..

However, I remember fixing this long time ago to use proper operation on
u8 values. It looks like I just have forgotten to submit those changes
to wireless-dev.git. There was quite a bit of additional cleanup, so it
would probably be best if I were to take a closer look at propose an
alternative patch for changing this and getting rid for struct
qos_control.

> +        u16 *p = (u16 *) (skb->data + ieee80211_get_hdrlen(fc) - 2);
> +        u16 qos_hdr = skb->priority & QOS_CONTROL_TAG1D_MASK;
>         if (local->wifi_wme_noack_test)
> -            qc->ack_policy = 1;
> +            qos_hdr |= QOS_CONTROL_ACK_POLICY_NOACK <<
> +                    QOS_CONTROL_ACK_POLICY_SHIFT;
> +        *p = cpu_to_le16(qos_hdr);

I think that this is always 16-bit aligned in the current
implementation, but I would be a bit careful with this type of change
here. This can be done easily with u8 since the qos_control field has 8
bits of used data and 8 bits of reserved field. My change was handling
this as two separate 8-bit values, so no issues with potential unaligned
accesses.

-- 
Jouni Malinen                                            PGP id EFC895FA
