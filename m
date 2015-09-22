From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC 0/3] kcm: Kernel Connection Multiplexor (KCM)
Date: Tue, 22 Sep 2015 09:46:38 -0700
Message-ID: <CALx6S34g3geNOjvxGbD_BtaquG-NmDkfkEyOwQygR3mEkSxa9Q@mail.gmail.com>
References: <1442788161-2626305-1-git-send-email-tom@herbertland.com>
	<56011C08.4070109@rockbox.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Thomas Martitz <kugel@rockbox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:36715 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244AbbIVQqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 12:46:39 -0400
Received: by igcrk20 with SMTP id rk20so84560121igc.1
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 09:46:39 -0700 (PDT)
In-Reply-To: <56011C08.4070109@rockbox.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 22, 2015 at 2:14 AM, Thomas Martitz <kugel@rockbox.org> wrote:
> Am 21.09.2015 um 00:29 schrieb Tom Herbert:
>>
>> Kernel Connection Multiplexor (KCM) is a facility that provides a
>> message based interface over TCP for generic application protocols.
>> The motivation for this is based on the observation that although
>> TCP is byte stream transport protocol with no concept of message
>> boundaries, a common use case is to implement a framed application
>> layer protocol running over TCP. To date, most TCP stacks offer
>> byte stream API for applications, which places the burden of message
>> delineation, message I/O operation atomicity, and load balancing
>> in the application. With KCM an application can efficiently send
>> and receive application protocol messages over TCP using a
>> datagram interface.
>>
>
>
> Hello Tom,
>
> on a general note I'm wondering what this offers over the existing SCTP
> support. SCTP offers reliable message exchange and multihoming already.
>
Hi Thomas,

The idea of KCM is to provide a an improved interface that is usable
with currently deployed protocols without invoking any change on the
wire whatsoever. Deploying SCTP to replace TCP use cases would entail
a major operations change for us, AFAIK hardware support is scant, and
we probably still can't reliably use it on the Internet (you can
Google why is SCTP not widely deployed). I would point out that two of
the four limitations of TCP listed in RFC4960 should be addressed by
KCM :-)

> On a specific note, I'm wondering if the dup(2) familiy of system calls
> isn't a lot more suitable/natural instead of overloading accept.
>
dup is to duplicate a file descriptor not a socket. Sockets operations
on duplicated file descriptors operate on the same socket, need to
contend for the socket lock, etc. This is a similar rationale as to
why we need SO_REUSEPORT instead of just dup'ing listener fds.

Thanks,
Tom

> Best regards.
