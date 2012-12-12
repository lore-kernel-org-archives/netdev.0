From: Weiping Pan <panweiping3@gmail.com>
Subject: Re: [RFC PATCH net-next 0/3 V4] net-tcp: TCP/IP stack bypass for
 loopback connections
Date: Wed, 12 Dec 2012 22:13:02 +0800
Message-ID: <50C890EE.7070704@gmail.com>
References: <CAEkNxbGTwGEBMCpSdib_paaxs0ekc52HWNo2Vai0nNSrZ1Zkng@mail.gmail.com>	<cover.1354674151.git.wpan@redhat.com> <20121210.160230.1883556145617090938.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wpan@redhat.com, netdev@vger.kernel.org, brutus@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:44970 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753257Ab2LLONB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 09:13:01 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so269292dak.19
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 06:13:01 -0800 (PST)
In-Reply-To: <20121210.160230.1883556145617090938.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/11/2012 05:02 AM, David Miller wrote:
> From: Weiping Pan<wpan@redhat.com>
> Date: Wed,  5 Dec 2012 10:54:16 +0800
>
>> Friends VS AF__UNIX
>> Their call path are almost the same, but AF_UNIX uses its own send/recv codes
>> with proper locks,
>> so AF_UNIX's performance is much better than Friends.
Sorry, this statement is not correct.
In TCP_STREAM case, if the message size if 16384, then AF_UNIX is much 
better than Friends.
If the message size is smaller, then Friends shows equal performance 
with AF_UNIX.
In TCP_RR,  Friends shows equal performance with AF_UNIX, too.

> While I understand the other portions of your analysis, this one
> mystifies me.
>
> In both cases, the sender has to queue the SKB onto the receiver's
> queue.  And in both cases, the sender takes the lock on that queue.
>
> So the locking contention really ought to be similar if not identical.
>
> The only difference is that AF_UNIX takes the unix_sk()->lock of the
> remote socket around these operations.
>
> If that is enough of a synchronizer to "fix" the contention or reduce
> it, then this would be very easy to test by adding a friend lock to
> tcp_sk().

I make some experiments to reduce the use of lock,
some performance results will be followed up.

thanks
Weiping Pan

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
