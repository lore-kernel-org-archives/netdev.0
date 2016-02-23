From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable outer Tx checksum by
 default
Date: Tue, 23 Feb 2016 13:26:17 -0500 (EST)
Message-ID: <20160223.132617.860625990168941692.davem@davemloft.net>
References: <CALx6S34Pt++Kg=cp+v+gGFQGEDy=eNHtFvtBwd1z-1d2ixOn7Q@mail.gmail.com>
	<CAEh+42iCxKb+OsMqR51nvzeCr_7n3WLncCaWNuctW7FbYijmCQ@mail.gmail.com>
	<CALx6S37p8eV-gURM0C8hP=G7XLt+=FFwV9HNF3z_FdciKxLf0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@kernel.org, ecree@solarflare.com, aduyck@mirantis.com,
	netdev@vger.kernel.org, alexander.duyck@gmail.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39908 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752415AbcBWS0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 13:26:19 -0500
In-Reply-To: <CALx6S37p8eV-gURM0C8hP=G7XLt+=FFwV9HNF3z_FdciKxLf0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 23 Feb 2016 09:42:00 -0800

> Why not just fix the stack to conform to RFC6864? As Edward pointed
> out we lose the actual IP ID's in GRO anyway, so attempts to set them
> in GSO may be wildly incorrect from the source point of view-- even in
> that case were probably better off changing the IP identifier to zero
> (okay since we're already breaking the E2E model anyway :-) ).

Tom, you can't, you'll break TCP header compression schemes which
expect a monotonically increasing IP ID value.

We tried setting the IP ID to zero for frames with DF set, it broke
things.
