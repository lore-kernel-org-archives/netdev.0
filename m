From: Pascal Terjan <pterjan@gmail.com>
Subject: Re: linux/atm_zatm.h not really usable in userspace since cf00713a655d3019be7faa184402f16c43a0fed3
Date: Sat, 15 Oct 2016 15:33:22 +0100
Message-ID: <CA+CX+bjXHVdoMzpKWX9jbBWbPhExq2CMnN+BgwhOOG2PBAfWBQ@mail.gmail.com>
References: <CA+CX+bjErkFu=VVv55PtiWg-Z88twBUyE20vo5A3fk9=ZD_LLw@mail.gmail.com>
 <20161015140906.GC2831@lakka.kapsi.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Mikko Rapeli <mikko.rapeli@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:34072 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753837AbcJOOeJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 10:34:09 -0400
Received: by mail-wm0-f54.google.com with SMTP id c78so4337008wme.1
        for <netdev@vger.kernel.org>; Sat, 15 Oct 2016 07:33:38 -0700 (PDT)
In-Reply-To: <20161015140906.GC2831@lakka.kapsi.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15 October 2016 at 15:09, Mikko Rapeli <mikko.rapeli@iki.fi> wrote:
> On Sat, Oct 15, 2016 at 01:05:10PM +0100, Pascal Terjan wrote:
>> It is no longer possible to include <linux/atm_zatm.h> + userspace
>> headers using time, for example  <stdlib.h>, this broke for example
>> the build of linux-atm.
>>
>> Reproducer:
>>
>> $ cat test.c
>> #include <linux/atm_zatm.h>
>> #include <stdlib.h>
>
> If possible, please reverse the order of includes to first include glibc
> headers and then Linux kernel uapi ones.

That was what I tried first but this didn't help:

In file included from /usr/include/linux/atm_zatm.h:17:0,
                 from test.c:2:
/usr/include/linux/time.h:9:8: error: redefinition of 'struct timespec'
 struct timespec {
        ^
In file included from /usr/include/sys/select.h:43:0,
                 from /usr/include/sys/types.h:219,
                 from /usr/include/stdlib.h:314,
                 from test.c:1:
/usr/include/time.h:120:8: note: originally defined here
 struct timespec
        ^
In file included from /usr/include/linux/atm_zatm.h:17:0,
                 from test.c:2:
/usr/include/linux/time.h:15:8: error: redefinition of 'struct timeval'
 struct timeval {
        ^
In file included from /usr/include/sys/select.h:45:0,
                 from /usr/include/sys/types.h:219,
                 from /usr/include/stdlib.h:314,
                 from test.c:1:
/usr/include/bits/time.h:30:8: note: originally defined here
 struct timeval
        ^
> Kernel uapi headers did not declare their header file dependencies correctly
> and I've been fixing them. I have also tried to fix compatibility issues
> with glibc headers, but unfortunately they only work when glibc headers
> are included before kernel headers. Userspace which has been relying on
> the magic include order for various uapi headers is now unfortunately
> affected. Sorry about that.

In this case no order works, it seems the kernel doesn't handle it in
time.h unlike many other headers
