From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sctp: fix NULL pointer dereference in
 af->from_addr_param on malformed packet
Date: Tue, 11 Nov 2014 15:20:09 -0500 (EST)
Message-ID: <20141111.152009.393006371622381121.davem@davemloft.net>
References: <1415638466-20176-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	vyasevich@gmail.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33085 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbaKKUUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 15:20:12 -0500
In-Reply-To: <1415638466-20176-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 10 Nov 2014 17:54:26 +0100

> An SCTP server doing ASCONF will panic on malformed INIT ping-of-death
> in the form of:
> 
>   ------------ INIT[PARAM: SET_PRIMARY_IP] ------------>
> 
> While the INIT chunk parameter verification dissects through many things
> in order to detect malformed input, it misses to actually check parameters
> inside of parameters. E.g. RFC5061, section 4.2.4 proposes a 'set primary
> IP address' parameter in ASCONF, which has as a subparameter an address
> parameter.
> 
> So an attacker may send a parameter type other than SCTP_PARAM_IPV4_ADDRESS
> or SCTP_PARAM_IPV6_ADDRESS, param_type2af() will subsequently return 0
> and thus sctp_get_af_specific() returns NULL, too, which we then happily
> dereference unconditionally through af->from_addr_param().
> 
> The trace for the log:
 ...
> A minimal way to address this is to check for NULL as we do on all
> other such occasions where we know sctp_get_af_specific() could
> possibly return with NULL.
> 
> Fixes: d6de3097592b ("[SCTP]: Add the handling of "Set Primary IP Address" parameter to INIT")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Vlad Yasevich <vyasevich@gmail.com>

Applied and queued up for -stable.
