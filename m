From: Tom Herbert <tom@herbertland.com>
Subject: Re: Performance comparision / qdisc / no qdisc / queueing linux
 kernel 4.12
Date: Sat, 12 Aug 2017 09:23:24 -0700
Message-ID: <CALx6S34=20JG5CApcBAx9ePnpjju80QgNd8p+0iYrM8q_qkk1A@mail.gmail.com>
References: <a59c1fdf-9c32-50f6-eb45-040e4ce30cff@itcare.pl>
 <fa7bc3ce-5dc7-e236-ec35-0afe3fc830bc@itcare.pl> <20170811161606.561b3fbb@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: =?UTF-8?Q?Pawe=C5=82_Staszewski?= <pstaszewski@itcare.pl>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:36501 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750864AbdHLQXZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2017 12:23:25 -0400
Received: by mail-qk0-f173.google.com with SMTP id d136so34074872qkg.3
        for <netdev@vger.kernel.org>; Sat, 12 Aug 2017 09:23:24 -0700 (PDT)
In-Reply-To: <20170811161606.561b3fbb@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 11, 2017 at 4:16 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> Any of the current qdisc that do rate control are single threaded.
> Since bandwidth is a shared resource, the qdisc has to acquire a lock
> and update cache shared data structures.
>
> Don't expect HTB or HFSC to be free.
>
This is a well known problem and there have been several attempts to
address it over the years (a long time ago at Google I implemented a
horrible hack called "hold queue" that put a parallelized queue in
front of HTB. This eliminated the lock contention, but not without
side effects).

Now there's a new scheduler proposed by some Googlers called Carousel
that promises scalable host traffic shaping
(https://www.cc.gatech.edu/~amsmti3/files/carousel-sigcomm17.pdf).
Looks like they didn't implement a kernel Qdisc, but might be
interesting for someone to look into...

Tom

>>
>> 4.13-rc3 have kernel panic when deleting qdisc - will try to get panic trace
>
> Please do.
>
