From: Jesse Gross <jesse@kernel.org>
Subject: Re: [net-next PATCH 2/2] VXLAN: Support outer IPv4 Tx checksums by default
Date: Fri, 19 Feb 2016 13:36:34 -0800
Message-ID: <CAEh+42iPR4LRLpQzV7bw21Q0h45t0WoE4RCg7tv-2TGbKSY-Yw@mail.gmail.com>
References: <20160219191806.15687.37621.stgit@localhost.localdomain>
 <20160219192631.15687.78165.stgit@localhost.localdomain> <CALx6S36VDm6Cku1bN-OvNAdu=U5TV-ZAMmStdsdmjWzbD+F3Ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:53352 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1424914AbcBSVgv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 16:36:51 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 8C5642050E
	for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 21:36:50 +0000 (UTC)
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 46F142049E
	for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 21:36:49 +0000 (UTC)
Received: by mail-qg0-f43.google.com with SMTP id b67so72225092qgb.1
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 13:36:49 -0800 (PST)
In-Reply-To: <CALx6S36VDm6Cku1bN-OvNAdu=U5TV-ZAMmStdsdmjWzbD+F3Ng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 19, 2016 at 12:27 PM, Tom Herbert <tom@herbertland.com> wrote:
> I would also note RFC7348 specifies:
>
> UDP Checksum: It SHOULD be transmitted as zero. ...
>
> The RFC doesn't provide any rationale as to why this is a SHOULD
> (neither is there any discussion as to whether this pertains to IPv6
> which has stronger requirements for non-zero UDP checksum). I think
> there are two possibilities in the intent: 1) The authors assume that
> computing UDP checksums is a significant performance hit which is
> dis-proven by this patch 2) They are worried about devices that are
> unable to compute receive checksums, however this would be addressed
> by an allowance that devices can ignore non-zero UDP checksums for
> VXLAN ("When a decapsulating end point receives a packet with a
> non-zero checksum, it MAY choose to verify the checksum value.")

It's #2.

All of the performance concerns around checksums and tunneling stem
from devices implemented using switching ASICs. In those devices,
computing/verifying checksums is so slow (software path) that they are
effectively unable to do it.
