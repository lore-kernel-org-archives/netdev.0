From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [PATCH iproute2] Use PATH_MAX instead of MAXPATHLEN
Date: Tue, 21 Jul 2015 22:40:32 +0200
Message-ID: <CAGm1_kv3HJpo_Z=T-qxWupuwOU5F2rO8rSr9HEZZONkch5DO9g@mail.gmail.com>
References: <20150425203327.GA9433@euler> <20150427091334.01323146@urahara>
 <55400DE7.9080501@gmail.com> <20150429165205.GA1364@euler>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Felix Janda <felix.janda@posteo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vn0-f45.google.com ([209.85.216.45]:34975 "EHLO
	mail-vn0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752510AbbGUUkx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 16:40:53 -0400
Received: by vnaa140 with SMTP id a140so40586890vna.2
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 13:40:52 -0700 (PDT)
In-Reply-To: <20150429165205.GA1364@euler>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 29, 2015 at 6:52 PM, Felix Janda <felix.janda@posteo.de> wr=
ote:
> Florian Fainelli wrote:
>> On 27/04/15 09:13, Stephen Hemminger wrote:
>> > On Sat, 25 Apr 2015 22:33:28 +0200
>> > Felix Janda <felix.janda@posteo.de> wrote:
>> >
>> >> They are equivalent but the former is more common. PATH_MAX is
>> >> specified by POSIX and needs <limits.h> while MAXPATHLEN has BSD
>> >> origin and needs <sys/param.h>.
>> >>
>> >> PATH_MAX has already been in use in misc/lnstat.h.
>> >>
>> >> Signed-off-by: Felix Janda <felix.janda@posteo.de>
>> >
>> > Iproute2 is intended for use on Linux.
>> > It makes more sense to align with Posix than using leftover
>> > BSD stuff. Therefore I don't see any point in doing this.
>>
>> My reading from Felix's commit message is that he is attempting to d=
o
>> exactly that: conform to POSIX rather than BSD, which seems to be th=
e
>> direction you are also suggesting here.
>> --
>> Florian
>
> This is correct. (In fact I misread the end of Stephen's message,
> thought that the patch was merged and wanted to thank for that.)

What's the status of this patch? This is one of the reasons iproute2
cannot be compiled against musl C library. After fixing this I get
tons of redefine errors:

In file included from ../include/linux/xfrm.h:4:0,
                 from xfrm_state.c:31:
=2E./include/linux/in6.h:32:8: error: redefinition of =E2=80=98struct i=
n6_addr=E2=80=99
 struct in6_addr {
        ^
In file included from
/home/user/Documents/versioned/buildroot/output/host/usr/arm-buildroot-=
linux-musleabi/sysroot/usr/include/netdb.h:9:0,
                 from xfrm_state.c:30:
/home/user/Documents/versioned/buildroot/output/host/usr/arm-buildroot-=
linux-musleabi/sysroot/usr/include/netinet/in.h:24:8:
note: originally defined here
 struct in6_addr
        ^
In file included from ../include/linux/xfrm.h:4:0,
                 from xfrm_state.c:31:
=2E./include/linux/in6.h:40:0: warning: "s6_addr" redefined
 #define s6_addr   in6_u.u6_addr8
 ^
In file included from
/home/user/Documents/versioned/buildroot/output/host/usr/arm-buildroot-=
linux-musleabi/sysroot/usr/include/netdb.h:9:0,
                 from xfrm_state.c:30:
/home/user/Documents/versioned/buildroot/output/host/usr/arm-buildroot-=
linux-musleabi/sysroot/usr/include/netinet/in.h:32:0:
note: this is the location of the previous definition
 #define s6_addr __in6_union.__s6_addr
 ^

Yegor
