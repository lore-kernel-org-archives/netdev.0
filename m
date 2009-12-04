From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: ipv4 05/05: add sysctl to accept packets with local source addresses
Date: Thu, 03 Dec 2009 23:52:56 -0800
Message-ID: <m13a3rfa5j.fsf@fess.ebiederm.org>
References: <20091203112550.15100.86217.sendpatchset@x2.localnet>
	<20091203112557.15100.85827.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:42353 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753692AbZLDHxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 02:53:03 -0500
In-Reply-To: <20091203112557.15100.85827.sendpatchset@x2.localnet> (Patrick McHardy's message of "Thu\,  3 Dec 2009 12\:25\:58 +0100 \(MET\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> writes:

> commit 8ec1e0ebe26087bfc5c0394ada5feb5758014fc8
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Thu Dec 3 12:16:35 2009 +0100
>
>     ipv4: add sysctl to accept packets with local source addresses
>     
>     Change fib_validate_source() to accept packets with a local source address when
>     the "accept_local" sysctl is set for the incoming inet device. Combined with the
>     previous patches, this allows to communicate between multiple local interfaces
>     over the wire.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>
>

Obligatory grumble. New binary sysctl.  Grumble.

Honestly this might be the one new sysctl that doesn't conflict with
my sysctl tree.  That should merge to Linus sometime this merge cycle
which will stop exporting this to userspace. So I don't have any
real complaints.  Grumble.

This overloading of sysctl.h for the binary sysctl numbers and
the index into the perdevice sysctls is something we should probably
change at some point to keep maintenance a little less confusing.

Eric


> diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
> index 1e4743e..9f047d7 100644
> --- a/include/linux/sysctl.h
> +++ b/include/linux/sysctl.h
> @@ -490,6 +490,7 @@ enum
>  	NET_IPV4_CONF_PROMOTE_SECONDARIES=20,
>  	NET_IPV4_CONF_ARP_ACCEPT=21,
>  	NET_IPV4_CONF_ARP_NOTIFY=22,
> +	NET_IPV4_CONF_ACCEPT_LOCAL=23,
>  	__NET_IPV4_CONF_MAX
>  };
>  
