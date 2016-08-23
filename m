From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] udp: fix poll() issue with zero sized packets
Date: Tue, 23 Aug 2016 13:56:34 -0700
Message-ID: <1471985794.14381.50.camel@edumazet-glaptop3.roam.corp.google.com>
References: <08d225a8-e98f-c0c6-271d-acc2584347fc@redhat.com>
         <20160823.112515.318902967155957764.davem@davemloft.net>
         <1471979019.14381.37.camel@edumazet-glaptop3.roam.corp.google.com>
         <f4d8b317-72bd-382d-f758-5fa997f1637b@redhat.com>
         <1471985604.14381.48.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, samanthakumar@google.com,
        willemb@google.com, netdev <netdev@vger.kernel.org>
To: Laura Abbott <labbott@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34474 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756004AbcHWU4h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 16:56:37 -0400
Received: by mail-pf0-f193.google.com with SMTP id g202so8849046pfb.1
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 13:56:36 -0700 (PDT)
In-Reply-To: <1471985604.14381.48.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-08-23 at 13:53 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
...

> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index e61f7cd65d08..2a2ac9e0c985 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1184,11 +1184,11 @@ out:
>   *	Drops all bad checksum frames, until a valid one is found.
>   *	Returns the length of found skb, or 0 if none is found.
>   */
> -static unsigned int first_packet_length(struct sock *sk)
> +static int first_packet_length(struct sock *sk)


I'll send a V2, updating the comment to :

Returns the length of found skb, or -1 if none is found.

(Thanks Willem for noticing this)
