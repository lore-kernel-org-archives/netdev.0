From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net-next] sock: ignore TIMESTAMP, RXQ_OVFL, WIFI_STATUS in sock_cmsg_send
Date: Fri, 13 May 2016 08:14:22 -0400
Message-ID: <CACSApvZpnu-F6Z7gH37Z942cDW0ruag+_jb_ukw+Vf5dvZk3cw@mail.gmail.com>
References: <1463114830-32751-1-git-send-email-soheil.kdev@gmail.com> <20160513.020356.2040257607864696950.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:35085 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139AbcEMMPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 08:15:03 -0400
Received: by mail-oi0-f48.google.com with SMTP id x19so166997846oix.2
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 05:15:03 -0700 (PDT)
In-Reply-To: <20160513.020356.2040257607864696950.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 13, 2016 at 2:03 AM, David Miller <davem@davemloft.net> wrote:
> From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
> Date: Fri, 13 May 2016 00:47:10 -0400
>
>> From: Soheil Hassas Yeganeh <soheil@google.com>
>>
>> SO_TIMESTAMP(NS), RXQ_OVFL, and WIFI_STATUS can be returned as
>> receive-side control messages from recvmsg(). Although invalid,
>> some applications may reflect those receive-side control messages
>> back to sendmsg(). Since socket-level control messages were being
>> ignored in ipv4 and ipv6, such applications would not get an error.
>>
>> 24025c4 (ipv4: process socket-level control messages in IPv4) and
>> ad1e46 (ipv6: process socket-level control messages in IPv6) add
>> support for socket-level control messages in ipv4 and ipv6 on
>> sendmsg(). This results in getting -EINVAL, if the application
>> passes in a message with SO_WIFI_STATUS, SO_RXQ_OVFL, SO_TIMESTAMP
>> and/or SO_TIMESTAMPNS that might have been received in recvmsg().
>>
>> Ignore SO_WIFI_STATUS, SO_TIMESTAMP(NS), and SO_RXQ_OVFL when
>> processing socket-level control messages in send-side to remain
>> backward compatible.
>
> This patch is missing a proper Signed-Off-By: tag.

Oops, sorry. :(

> But I think this change is wrong.  Just because we silently accepted
> garbage in the past doesn't mean more strict checking is invalid.
>
> Applications blindly echoing control messages from recvmsg to sendmsg
> must be fixed.

Agreed, by this patch, I just wanted to note such potential issues and
make sure I haven't broken any user-space application. Thanks David!
