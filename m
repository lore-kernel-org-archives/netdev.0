From: Jesse Gross <jesse@nicira.com>
Subject: Re: [-next] openvswitch BUILD_BUG_ON failed
Date: Thu, 29 Aug 2013 14:42:22 -0700
Message-ID: <CAEP_g=-XvRiHPzSAp2rgC9Hxdd+pGEHvSTEJ1A1SkWnk1-6xZA@mail.gmail.com>
References: <CAMuHMdVG9FmZNayrf7HMz4kC4X5QELeXUFjjzpAM80ND_QOm8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Zhou <azhou@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linux-Next <linux-next@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:42968 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751968Ab3H2Vmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 17:42:45 -0400
Received: by mail-la0-f47.google.com with SMTP id eo20so859009lab.6
        for <netdev@vger.kernel.org>; Thu, 29 Aug 2013 14:42:42 -0700 (PDT)
In-Reply-To: <CAMuHMdVG9FmZNayrf7HMz4kC4X5QELeXUFjjzpAM80ND_QOm8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 29, 2013 at 2:21 PM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> However, I have some doubts about other alignment "enforcements":
>
> "__aligned(__alignof__(long))" makes the whole struct aligned to the
> alignment rule for "long":
>    1. This is only 2 bytes on m68k, i.e. != sizeof(long).
>    2. This is 4 bytes on many 32-bit platforms, which may be less than the
>       default alignment for "__be64" (cfr. some members of struct
>       ovs_key_ipv4_tunnel), so this may make those 64-bit members unaligned.

Do any of those 32-bit architectures actually care about alignment of
64 bit values? On 32-bit x86, a long is 32 bits but the alignment
requirement of __be64 is also 32 bit.
