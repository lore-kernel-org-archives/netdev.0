From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/5 v2] sunrpc: Remove sk_no_check setting
Date: Wed, 21 May 2014 14:15:33 -0700
Message-ID: <CA+mtBx-WURWvoj9CHRD_-_Ko6k3D-DJbJCqtcUao72jqSZxKVQ@mail.gmail.com>
References: <alpine.DEB.2.02.1405120946520.551@tomh.mtv.corp.google.com>
	<20140521.163735.1815284886558779067.davem@davemloft.net>
	<CA+mtBx9Un_+gw420dRz2_+oiOj4yii0mWQLN5DTxBJ+r0JQJ0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:60263 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786AbaEUVPe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 17:15:34 -0400
Received: by mail-ie0-f176.google.com with SMTP id rl12so2625941iec.21
        for <netdev@vger.kernel.org>; Wed, 21 May 2014 14:15:34 -0700 (PDT)
In-Reply-To: <CA+mtBx9Un_+gw420dRz2_+oiOj4yii0mWQLN5DTxBJ+r0JQJ0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 21, 2014 at 2:14 PM, Tom Herbert <therbert@google.com> wrote:
>
>
>
>
> On Wed, May 21, 2014 at 1:37 PM, David Miller <davem@davemloft.net> wrote:
>>
>> From: Tom Herbert <therbert@google.com>
>> Date: Mon, 19 May 2014 10:09:56 -0700 (PDT)
>>
>> > Setting sk_no_check to UDP_CSUM_NORCV seems to have no effect.
>> >
>> > Signed-off-by: Tom Herbert <therbert@google.com>
>>
>> It does have an effect.
>>
>> All of the UDP receive paths check for sk->sk_no_check being non-zero,
>> causing it to accept packets with a zero checksum.
>>
>> You're changing behavior here.
>
>
> We always accept zero UDP checksums for IPv4, there is currently no way to disable that (sk_no_check should not affect that). For IPv6 UDP, I intend to make allowing zero RX checksums not to be default and must be explicitly configured. I'm not sure if sunrpc qualifies as a protocol for which zero v6 csums should be allowed, but in any case since we weren't accepting any v6 zero csums before there is no behavior change in that case either.
>
