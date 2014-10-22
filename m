From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH net-next] tcp: Add TCP_FREEZE socket option
Date: Wed, 22 Oct 2014 18:10:25 +0200
Message-ID: <CAKfDRXh5t9n2G7Af_4ZDOTbXO9_nA30vrxTcgy+_wGDE8m_+nQ@mail.gmail.com>
References: <1413992196-4891-1-git-send-email-kristian.evensen@gmail.com>
	<1413993272.9031.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:60141 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753426AbaJVQK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 12:10:26 -0400
Received: by mail-yh0-f44.google.com with SMTP id i57so3737756yha.17
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 09:10:25 -0700 (PDT)
In-Reply-To: <1413993272.9031.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Oct 22, 2014 at 5:54 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> This asymmetry looks strange
>
> Following sequence should be allowed :
>
> getsockopt(...  TCP_FREEZE, &val, ...)
> setsockopt(...  TCP_FREEZE, &val, ...)
>
> So setsockopt() should accept val = 0

Thanks for you comment and I agree. The reasoning behind my original
ordering was that I wanted the values to be in the order which made
most logical sense to me, which is Enable (1), Disable (2) and Disable
with TR-ACK (3). However, I see now that when using the option and
when combined with getsockopt(), this does not make much sense. I will
wait for some more feedback and send a revised version tomorrow with
the following ordering: Disable (0), Enable (1), Disable with TR-ACK
(2).

Thanks again,
Kristian
