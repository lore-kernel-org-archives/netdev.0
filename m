From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] bridge: allow receiption on disabled port
Date: Thu, 10 Oct 2013 13:36:46 -0700
Message-ID: <20131010133646.1bdd42c1@nehalam.linuxnetplumber.net>
References: <1381409570-1892-1-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:45925 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755931Ab3JJUgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 16:36:50 -0400
Received: by mail-pa0-f51.google.com with SMTP id kp14so3323222pab.10
        for <netdev@vger.kernel.org>; Thu, 10 Oct 2013 13:36:50 -0700 (PDT)
In-Reply-To: <1381409570-1892-1-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Oct 2013 14:52:50 +0200
Felix Fietkau <nbd@openwrt.org> wrote:

> When an ethernet device is enslaved to a bridge, and the bridge STP
> detects loss of carrier (or operational state down), then normally
> packet receiption is blocked.
> 
> This breaks control applications like WPA which maybe expecting to
> receive packets to negotiate to bring link up. The bridge needs to
> block forwarding packets from these disabled ports, but there is no
> hard requirement to not allow local packet delivery.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>

No. This will cause duplicate packets to be delivered.

If doing a link layer protocol like WPA then it should be done directly
on the underlying device, not the bridge itself.
