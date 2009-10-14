From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: query: bnx2 and tg3 don't check tcp and/or ip header length
 validity?
Date: Wed, 14 Oct 2009 14:24:18 -0700
Message-ID: <1255555458.20869.221.camel@nseg_linux_HP1.broadcom.com>
References: <4AD5F333.3040002@gmail.com>  <4AD638AC.3000901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "William Allen Simpson" <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1815 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754543AbZJNVfF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 17:35:05 -0400
In-Reply-To: <4AD638AC.3000901@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2009-10-14 at 13:46 -0700, William Allen Simpson wrote:
> William Allen Simpson wrote:
> > My question is whether it would be OK to add a simple test, and set it to
> > zero in case of bad values?
> > 
> Although both are compiled in my build, I've got no way to test them.  I'm
> just going to do the easy thing and set to zero for now.  Somebody that
> knows the code -- who should have done real error checking -- could actually
> write better error checking and comments about the purpose of cramming the
> length of the TCP option field into a tag....

The option length is needed by the hardware to segment a TSO packet into
proper MTU-sized packets.  You'll get malformed packets if the TSO
header is bad.  Setting it to zero perhaps can make these bad packets
more deterministic, but I don't know for sure.

> 
> -		tcp_opt_len = tcp_optlen(skb);
> +		tcp_opt_len = tcp_option_len_th(tcp_hdr(skb));
> +		if (tcp_opt_len < 0)
> +			tcp_opt_len = 0;
> 



