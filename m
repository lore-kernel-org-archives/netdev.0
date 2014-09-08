From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next v1 2/2] bonding: Simplify the xmit function for
 modes that use xmit_hash
Date: Sun, 7 Sep 2014 21:51:15 -0700
Message-ID: <CAF2d9jhevnUaUt8_0sdffXz6--TcEvtAbMQwwFiZ+Eb0Ms_T5A@mail.gmail.com>
References: <1409985356-2384-1-git-send-email-maheshb@google.com>
 <540AE9CC.10206@redhat.com> <CAF2d9jhXEMZF-W+wYns4NCiJ1W2LjDoNEmO2X-3791DmbYaDkg@mail.gmail.com>
 <540C351F.9070800@redhat.com> <CAF2d9jhF-utP0pyZNObmr9j4V8Hyp4qsf-NdseDF9Ka=24x+eA@mail.gmail.com>
 <1410151290.11872.80.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f169.google.com ([209.85.220.169]:34737 "EHLO
	mail-vc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751685AbaIHEvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 00:51:36 -0400
Received: by mail-vc0-f169.google.com with SMTP id hq11so15097558vcb.28
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2014 21:51:35 -0700 (PDT)
In-Reply-To: <1410151290.11872.80.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 7, 2014 at 9:41 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2014-09-07 at 19:23 -0700, Mahesh Bandewar wrote:
>> >
>> I'm not expecting any writer protection here since all the paths are
>> covered with some or the other lock at this moment. Just though that
>> performing array manipulation in RCU context would be useful.
>
>
> It is not useful. It is confusing only.
>
> If you think of RCU as a replacement for reader/writer lock, its obvious
> that once you get the writer lock, there is no need to get the reader
> lock.
>
As I had mentioned earlier, simultaneous writers are taken care. The
xmit is lockless and was thinking about how not to get the xmit into
the scenario where this array manipulation is partially done and that
partial value is used by the xmitter and result may not be desirable.
Hence thought that rcu-read-lock will protect the xmitter getting into
that state. I guess that was incorrect so I'll remove the
read-lock/unlock from the code. Thanks for the clarification Eric.

> Extract from Documentation/RCU/whatisRCU.txt :
>
> Use rcu_read_lock() and rcu_read_unlock() to guard RCU
> read-side critical sections.
>
> Use some solid scheme (such as locks or semaphores) to
> keep concurrent updates from interfering with each other.
>
>
>
