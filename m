From: Abhijit Karmarkar <awk@google.com>
Subject: Re: ipsec performance
Date: Tue, 29 Dec 2009 14:55:13 -0800
Message-ID: <88cc3e770912291455w240d543atadbcbdd22746c@mail.gmail.com>
References: <f5327b860912291309g701d6345k6517a4eb75830faf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: schuldei@spotify.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:47671 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752742AbZL2WzR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2009 17:55:17 -0500
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id nBTMtEVW001821
	for <netdev@vger.kernel.org>; Tue, 29 Dec 2009 22:55:15 GMT
Received: from pxi32 (pxi32.prod.google.com [10.243.27.32])
	by wpaz24.hot.corp.google.com with ESMTP id nBTMssGs009239
	for <netdev@vger.kernel.org>; Tue, 29 Dec 2009 14:55:13 -0800
Received: by pxi32 with SMTP id 32so7612335pxi.15
        for <netdev@vger.kernel.org>; Tue, 29 Dec 2009 14:55:13 -0800 (PST)
In-Reply-To: <f5327b860912291309g701d6345k6517a4eb75830faf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 29, 2009 at 1:09 PM, Andreas Schuldei <schuldei@spotify.com=
> wrote:
> hi!
>
> i experience performance issues with ipsec transport mode with debian
> lenny and strongswan, on a stock debian kernel 2.6.26-2-amd64.
>
> the goal is to set up a full mash of several hundred hosts, talking
> ipsec with each other, in order to be able to skip firewalls and to b=
e
> able to let the hosts be spread out over several sites in a
> transparent fashion.
>
> regardless of the cipher (i tried aes and blowfish) the bandwidth
> maxes out at about 0.5-0.25 of the expected (unencrypted) value,
> without hitting obvious bottlenecks like cpu, disk, or ram.

you may want try Steffen Klassert's parallel crypto patches (nice work!=
):

  http://marc.info/?l=3Dlinux-kernel&m=3D126155699817914&w=3D2

the numbers are impressive. i plan to try them sometime this (or next w=
eek).

yes, on the current kernels, the ipsec throughput numbers are around
50% of the non-ipsec case. for me.


>
> tcpdump shows packages below the MTU (which is 1500):
>
> 20:25:03.313469 IP 78.31.14.86 > 78.31.14.93:
> ESP(spi=3D0xc929dbe8,seq=3D0x100a87), length 1332
> 20:25:03.313514 IP 78.31.14.86 > 78.31.14.93:
> ESP(spi=3D0xc929dbe8,seq=3D0x100a88), length 1476
> 20:25:03.313529 IP 78.31.14.93 > 78.31.14.86:
> ESP(spi=3D0xc4967810,seq=3D0x7bcd1), length 68
> 20:25:03.313557 IP 78.31.14.86 > 78.31.14.93:
> ESP(spi=3D0xc929dbe8,seq=3D0x100a89), length 1476
> 20:25:03.313603 IP 78.31.14.86 > 78.31.14.93:
> ESP(spi=3D0xc929dbe8,seq=3D0x100a8a), length 1332
> 20:25:03.313605 IP 78.31.14.86 > 78.31.14.93:
> ESP(spi=3D0xc929dbe8,seq=3D0x100a8a), length 1332
> 20:25:03.313606 IP 78.31.14.93 > 78.31.14.86:
> ESP(spi=3D0xc4967810,seq=3D0x7bcd2), length 68
> 20:25:03.313649 IP 78.31.14.86 > 78.31.14.93:
> ESP(spi=3D0xc929dbe8,seq=3D0x100a8b), length 1476
>
> how can i inspect window size, fragmentation etc? are there useful
> files in /proc or /sys or enlightening ip commands?
>
> /andreas
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
