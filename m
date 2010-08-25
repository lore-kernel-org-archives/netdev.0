From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next 2/2] macvlan:  Enable qdisc backoff logic.
Date: Wed, 25 Aug 2010 21:24:09 +0200
Message-ID: <201008252124.09917.arnd@arndb.de>
References: <1282762851-3612-1-git-send-email-greearb@candelatech.com> <1282762851-3612-2-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:61096 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474Ab0HYTYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 15:24:14 -0400
In-Reply-To: <1282762851-3612-2-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 25 August 2010 21:00:51 Ben Greear wrote:
> This allows macvlans to apply backpressure to calling code
> in the transmit path when the underlying qdisc cannot accept
> additional packets.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>

Ah, very nice! I was wondering how to do this.

I suppose we need to do something in macvtap to handle this as
well, right? A guest trying to send a frame through qemu
or vhost net into macvtap needs to be prevented from sending
more when we get into this path. Right now, we just ignore
the return value of macvlan_start_xmit.

	Arnd
