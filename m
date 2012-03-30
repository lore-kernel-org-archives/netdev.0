From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP_MAXSEG option with TSO enabled
Date: Fri, 30 Mar 2012 10:38:00 -0700
Message-ID: <4F75EF78.4060402@hp.com>
References: <CAEnQRZC1sLW8BUOx2ov-S-UUSyfAi7Wem2mAzUHBHn2o9q-eRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Baluta <daniel.baluta@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:6714 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741Ab2C3RiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2012 13:38:03 -0400
In-Reply-To: <CAEnQRZC1sLW8BUOx2ov-S-UUSyfAi7Wem2mAzUHBHn2o9q-eRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/30/2012 04:33 AM, Daniel Baluta wrote:
> Hello,
>
> I am using TCP_MAXSEG option on an interface which has TSO enabled.
>
> strace output for connection looks as follows:
>
> socket(PF_INET, SOCK_STREAM, IPPROTO_IP) = 26
> setsockopt(26, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
> setsockopt(26, SOL_TCP, TCP_NODELAY, [1], 4) = 0
> setsockopt(26, SOL_TCP, TCP_MAXSEG, [300], 4) = 0
> connect(26, {sa_family=AF_INET, sin_port=htons(1935),
> sin_addr=inet_addr("10.10.0.1")}, 16) = -1 EINPROGRESS (Operation now
> in progress)
>
> I can see that MSS (300) is advertised in SYN packet, anyhow capturing
> the traffic
> I notice that are some TCP segments with length greater than MSS.
>
> Is this normal taking in consideration that TSO is enabled?

I would think so.  What do the netstat stats suggest for segments and 
bytes per segment when you are running your test?  You could always look 
for an on-the-wire packet trace.

Not sure that a trace on a receiver would give you that though - the 
inbound promiscuous tap may be above GRO (and almost certainly will be 
above LRO)

rick jones

>
> thanks,
> Daniel.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
