From: Alexey Orishko <alexey.orishko@gmail.com>
Subject: Re: the side effect of using copy skb instead of skb_clone in cdc
 ncm/mbim driver
Date: Thu, 10 Jul 2014 01:41:37 +0200
Message-ID: <CAL_Kpj0-g-o5yKJQu=oh773ugfYi-=pjVkJ8-N5OCyuz2EYWOw@mail.gmail.com>
References: <CAOa2BBy4t_17J7G5bBpAZZpBWZYh+Cpc6Fn4u+9cV98M8CZ5gw@mail.gmail.com>
	<87y4w4jprx.fsf@nemi.mork.no>
	<CAOa2BBwVxcC_WoAqExRgEX57BwkikOL_sOBnjus+udNzVB0zqw@mail.gmail.com>
	<87zjgih66u.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: joey ming <joey.zming@gmail.com>, jim_baxter@mentor.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	zhao.ming9@zte.com.cn
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:56203 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbaGIXlh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 19:41:37 -0400
Received: by mail-qc0-f181.google.com with SMTP id x13so7195616qcv.40
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2014 16:41:37 -0700 (PDT)
In-Reply-To: <87zjgih66u.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 9, 2014 at 6:01 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote:
> Alexey's results were on modem hardware, and I am guessing the OS was=
n't
> Linux.
NCM driver was deployed on Unix-like realtime OS and on various
embedded application CPU running Android.

> So NCM is probably a great win for the modems,
> and you are right: That is likely why this aggregating protocol was
> invented.

One comment for this and earlier passages about USB-IF: during
specification development there was no intention "to make life easier"
on the host side, the goal was to make mobile device more efficient
with a weak CPU (since 2007 situation changed significantly for mobile
computing power).

One important comment though about the main idea of the aggregation pro=
tocol:
- in order to get a *real* benefit of the protocol sender shall
initially send only a table containing pointers in a separate 512
bytes packet and only then send the rest of NTB.
- receiving side shall allocate DMA job for receiving 512 bytes first
and after parsing it, setup a job for receiving all IP packets into
separate data buffers. After that DMA engine will handle data without
involving CPU.
As a result: minimum CPU usage and all IP packets are placed into
separate skb-s.

However, I don't believe usbnet infrastructure is capable of doing
that, but it can be done in proprietary code in usb modem. I don't
have any info if someone actually manage to build such a system, which
required a lot of efforts; it is much easier to do data coping with
Intel Quad Core 3+GHz CPU with 8+GB RAM - you hardly notice any
difference comparing to embedded systems...

Regards,
Alexey
