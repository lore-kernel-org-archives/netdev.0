From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bna: fix Rx data corruption with VLAN stripping
 enabled and MTU > 4096
Date: Fri, 15 Jan 2016 15:06:40 -0500 (EST)
Message-ID: <20160115.150640.705301645168086217.davem@davemloft.net>
References: <1452861928-17069-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rasesh.mody@qlogic.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32914 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464AbcAOUGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 15:06:42 -0500
In-Reply-To: <1452861928-17069-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Fri, 15 Jan 2016 13:45:28 +0100

> The multi-buffer Rx mode implemented in the past introduced
> a regression that causes a data corruption for received VLAN
> traffic when VLAN tag stripping is enabled. This mode is supported
> only be newer chipsets (1860) and is enabled when MTU > 4096.
> 
> When this mode is enabled Rx queue contains buffers with fixed size
> 2048 bytes. Any incoming packet larger than 2048 is divided into
> multiple buffers that are attached as skb frags in polling routine.
> 
> The driver assumes that all buffers associated with a packet except
> the last one is fully used (e.g. packet with size 5000 are divided
> into 3 buffers 2048 + 2048 + 904 bytes) and ignores true size reported
> in completions. This assumption is usually true but not when VLAN
> packet is received and VLAN tag stripping is enabled. In this case
> the first buffer is 2044 bytes long but as the driver always assumes
> 2048 bytes then 4 extra random bytes are included between the first
> and the second frag. Additionally the driver sets checksum as correct
> so the packet is properly processed by the core.
> 
> The driver needs to check the size of used space in each Rx buffer
> reported by FW and not blindly use the fixed value.
> 
> Cc: Rasesh Mody <rasesh.mody@qlogic.com>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Rasesh, please review.
