From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH #2] [8021Q]: Turn off all the hardware VLAN features for promisc
Date: Fri, 21 Mar 2008 01:46:02 +0900
Message-ID: <b25c3fa70803200946w15ef6d27p4cbf84db7a621756@mail.gmail.com>
References: <20080319081110.GA12081@tp61p-64> <47E278B2.1000102@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.177]:44220 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754093AbYCTQqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 12:46:06 -0400
Received: by el-out-1112.google.com with SMTP id v27so766615ele.17
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2008 09:46:03 -0700 (PDT)
In-Reply-To: <47E278B2.1000102@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/3/20, Patrick McHardy <kaber@trash.net>:
>
> I think a better way to handle this would be to make packet
> sockets understand VLAN accerlation, similar to partial
> checksums. This would mean on TX we get the tag from the
> packets meta data and put it in the auxillary data.
> RX should probably be handled by the driver by disabling
> VLAN filtering when promiscous mode is enabled.
>
> VLAN stripping would currently also have to be disabled,
> but since its necessary to move the tag from the CB
> to the skb anyways for avoiding qdiscs trampling over
> it, once we've done that we could keep stripping enabled
> and also store the VID on RX and make it visible to
> packet sockets.
>
> This would require to teach userspace about the new
> auxillary data, but allows to use tcpdump and vlan
> accerlation at the same time and doesn't require to
> disabling accerlation when going to promiscous mode
> for other reasons (like secondary unicast addresses).
>

Thanks Patrick for reviewing this and show me the better way.

To summarize your say, disable VLAN filtering by driver handling and
push new auxillary data to packet socket for RX & TX. Right?

Actually for the VLAN filtering, It seemed possible to disable it
without fixing every driver codes relatively easily, but for now it
might not be a proper way I think.
Also I did concern a situation 'promiscuous without tcpdump' like
secondary unicast addresses.
I think the opinion that you said is the solution.
Thanks again.
I'll try these things.

Joonwoo,
