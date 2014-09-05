From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] dev_ioctl: remove dev_load() CAP_SYS_MODULE
 message
Date: Fri, 05 Sep 2014 12:05:00 -0700 (PDT)
Message-ID: <20140905.120500.1765085127279000120.davem@davemloft.net>
References: <1409693405-24671-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, stephen@networkplumber.org,
	netdev@vger.kernel.org, segoon@openwall.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54840 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754360AbaIETFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 15:05:01 -0400
In-Reply-To: <1409693405-24671-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue,  2 Sep 2014 23:30:05 +0200

> Marcel reported to see the following message when autoloading
> is being triggered when adding nlmon device:
> 
>   Loading kernel module for a network device with
>   CAP_SYS_MODULE (deprecated). Use CAP_NET_ADMIN and alias
>   netdev-nlmon instead.
> 
> This false-positive happens despite with having correct
> capabilities set, e.g. through issuing `ip link del dev nlmon`
> more than once on a valid device with name nlmon, but Marcel
> has also seen it on creation time when no nlmon module is
> previously compiled-in or loaded as module and the device
> name equals a link type name (e.g. nlmon, vxlan, team).
> 
> Stephen says:
> 
>   The netdev module alias is a hold over from the past. For
>   normal devices, people used to create a alias eth0 to and
>   point it to the type of network device used, that was back
>   in the bad old ISA days before real discovery.
> 
>   Also, the tunnels create module alias for the control device
>   and ip used to use this to autoload the tunnel device.
> 
>   The message is bogus and should just be removed, I also see
>   it in a couple of other cases where tap devices are renamed
>   for other usese.
> 
> As mentioned in 8909c9ad8ff0 ("net: don't allow CAP_NET_ADMIN
> to load non-netdev kernel modules"), we nevertheless still
> might want to leave the old autoloading behaviour in place
> as it could break old scripts, so for now, lets just remove
> the log message as Stephen suggests.
> 
> Reference: http://thread.gmane.org/gmane.linux.kernel/1105168
> Reported-by: Marcel Holtmann <marcel@holtmann.org>
> Suggested-by: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Vasiliy Kulikov <segoon@openwall.com>
> ---
>  (Sending to net-next as I don't think it's very urgent.)

Applied, thanks Daniel.
