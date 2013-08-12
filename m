From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: SCTP and IP_TOS
Date: Mon, 12 Aug 2013 16:21:54 -0400
Message-ID: <520943E2.7010408@gmail.com>
References: <52091492.9060904@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f170.google.com ([209.85.128.170]:48887 "EHLO
	mail-ve0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254Ab3HLUV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 16:21:58 -0400
Received: by mail-ve0-f170.google.com with SMTP id 15so6052404vea.15
        for <netdev@vger.kernel.org>; Mon, 12 Aug 2013 13:21:57 -0700 (PDT)
In-Reply-To: <52091492.9060904@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/12/2013 01:00 PM, Ben Greear wrote:
> Hello!
>
> I notice that I read 0x2 as IP_TOS getsockopt on an SCTP socket configured
> for streaming mode.
>
> Looks to me like the reason is that SCTP uses a socket type of
> SCTP_SOCKET_TCP
> and the ipv4/ip_sockglue.c code is only masking out ECN for SOCK_STREAM
> types.
>
> Is this per design, or should the ip_sockglue.c mask out ECN for
> SCTP_SOCKET_TCP
> types as well?
>
> Thanks,
> Ben
>

 From the ip_glue perspective, you would see either SOCK_STREAM or
SOCK_SEQPACKET.

So you are trying to set tos bits on a SEQPACKET socket, ip_sockglue()
wouldn't try preserver current ECN bits as it does for STREAM sockets.

-vlad
