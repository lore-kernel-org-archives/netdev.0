From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Why ECONNREFUSED from unix_dgram_sendmsg?
Date: Thu, 11 Sep 2014 17:58:59 +0200
Message-ID: <1410451139.2693347.166368361.32138EFC@webmail.messagingengine.com>
References: <CALCETrUM1P0Sydps_4-5yPBOBD35zOcpACv-OX8b==xT0BC1xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Andy Lutomirski <luto@amacapital.net>,
	Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:36213 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751220AbaIKP7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 11:59:00 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway2.nyi.internal (Postfix) with ESMTP id 1D076209C7
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 11:59:00 -0400 (EDT)
In-Reply-To: <CALCETrUM1P0Sydps_4-5yPBOBD35zOcpACv-OX8b==xT0BC1xw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, Sep 11, 2014, at 17:11, Andy Lutomirski wrote:
> What is unix_dgram_sendmsg trying to tell me here?
> 
>         if (sock_flag(other, SOCK_DEAD)) {
>                 /*
>                  *      Check with 1003.1g - what should
>                  *      datagram error
>                  */
>                 unix_state_unlock(other);
>                 sock_put(other);
> 
>                 err = 0;
>                 unix_state_lock(sk);
>                 if (unix_peer(sk) == other) {
>                         unix_peer(sk) = NULL;
>                         unix_state_unlock(sk);
> 
>                         unix_dgram_disconnected(sk, other);
>                         sock_put(other);
>                         err = -ECONNREFUSED;
> 
> I'm getting this intermittently on a seqpacket socket when the other
> end dies.  Shouldn't this be -ECONNRESET?
> 
> git blame doesn't tell me anything here -- this code predates git.

Changelogs were not that descriptive as they were today: :)

commit 283fd6cf0be690a83b5dbb34e79130f8592c0765
Author: davem <davem>
Date:   Fri Aug 20 10:59:51 1999 +0000

    Merge in ANK networking jumbo patch,
    which includes ATM from Werner Almesberger, Netfilter
    from Paul Russell, and massive SMP networking enhancements
    by Alexey.

(in
https://git.kernel.org/cgit/linux/kernel/git/davem/netdev-vger-cvs.git/)

I agree, -ECONNRESET would be a better errno value, but this is hard to
change because of backwards compatibility.

Bye,
Hannes
