From: nello martuscielli <ppc.addon@gmail.com>
Subject: Re: iproute-3.8.0 build error on Linux ppc64
Date: Wed, 27 Feb 2013 17:27:30 +0100
Message-ID: <CABMX=WyV7t-RcdM103z9sqvvicxvnTtX-OW_OyL9MA5j_4ho1w@mail.gmail.com>
References: <CABMX=WwSNeTq_ascBRxJtQrsErR-cFODZQh_wrim6K8weyLDtQ@mail.gmail.com>
	<CABMX=WxaxNhvx4YA6-KiDjoRURXsotCSEpxQJu4mK11UtW78jw@mail.gmail.com>
	<20130227072830.6ab4373e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f179.google.com ([209.85.220.179]:45863 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756790Ab3B0Q1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 11:27:31 -0500
Received: by mail-vc0-f179.google.com with SMTP id k1so500286vck.38
        for <netdev@vger.kernel.org>; Wed, 27 Feb 2013 08:27:31 -0800 (PST)
In-Reply-To: <20130227072830.6ab4373e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 27, 2013 at 4:28 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:

__omissis
>> >
>> > gcc -Wall -Wstrict-prototypes -Werror -Wmissing-prototypes
>> > -Wmissing-declarations -Wold-style-definition -O2 -I../include
>> > -DRESOLVE_HOSTNAMES -DLIBDIR=\"/usr/lib\" -DCONFDIR=\"/etc/iproute2\"
>> > -D_GNU_SOURCE   -c -o ipntable.o ipntable.c
>> > cc1: warnings being treated as errors
>> > ipntable.c: In function 'print_ntable':
>> > ipntable.c:435:3: error: format '%llu' expects type 'long long
>
> Pushed up a fix for this using casts.
> Would rather have used inttypes.h but that was incompatible with kernel's __u64.


thanks a lot, this fix ipntable.c .
Now I got this same type build error on tcp_metrics.c

[...]
gcc -Wall -Wstrict-prototypes -Werror -Wmissing-prototypes
-Wmissing-declarations -Wold-style-definition -O2 -I../include
-DRESOLVE_HOSTNAMES -DLIBDIR=\"/usr/lib\" -DCONFDIR=\"/etc/iproute2\"
-D_GNU_SOURCE   -c -o tcp_metrics.o tcp_metrics.c
cc1: warnings being treated as errors
tcp_metrics.c: In function 'process_msg':
tcp_metrics.c:172:4: error: format '%llu' expects type 'long long
unsigned int', but argument 3 has type '__u64'
tcp_metrics.c:172:4: error: format '%03llu' expects type 'long long
unsigned int', but argument 4 has type '__u64'
tcp_metrics.c:232:4: error: format '%llu' expects type 'long long
unsigned int', but argument 4 has type '__u64'
tcp_metrics.c:232:4: error: format '%03llu' expects type 'long long
unsigned int', but argument 5 has type '__u64'
make[1]: *** [tcp_metrics.o] Error 1
make[1]: Leaving directory `/root/iproute2-3.8.0/ip'
make: *** [all] Error 2



Nello
--
LinuxPPC64 user.
