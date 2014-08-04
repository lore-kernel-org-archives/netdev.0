From: Neal Cardwell <ncardwell@google.com>
Subject: Fwd: Fw: [Bug 81661] New: Network Performance Regression for large
 TCP transfers starting with v3.10
Date: Mon, 4 Aug 2014 13:08:51 -0400
Message-ID: <CADVnQynpqRkkY8eYrDZkkHUwyRgQsahyqVoU=T89ggG4xZi-Ww@mail.gmail.com>
References: <20140804090529.1a5d146d@haswell.linuxnetplumber.net>
	<CADVnQy=mp+m3s1xp7cZ0r4gpwHbMAnBNxAxcQx-AUtB7dZieiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Yuchung Cheng <ycheng@google.com>
To: Alexander.Steffen@infineon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:38848 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279AbaHDRIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 13:08:55 -0400
Received: by mail-wg0-f46.google.com with SMTP id m15so7970218wgh.17
        for <netdev@vger.kernel.org>; Mon, 04 Aug 2014 10:08:52 -0700 (PDT)
In-Reply-To: <CADVnQy=mp+m3s1xp7cZ0r4gpwHbMAnBNxAxcQx-AUtB7dZieiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 4, 2014 at 12:05 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> https://bugzilla.kernel.org/show_bug.cgi?id=81661
>
>             Bug ID: 81661
>            Summary: Network Performance Regression for large TCP transfers
>                     starting with v3.10

[sorry for re-send; fixing typo in e-mail address...]

Hi Alexander,

Thanks for the detailed report!

We think we have a sense of what might be happening, but the traces
are a little hard to interpret.

The  capture-bad-site1 trace seems to be a sender-side trace that
shows SACK blocks with sequence numbers that are 613M bytes ahead of
what has actually been sent, suggesting perhaps a middlebox is
rewriting sequence numbers, but not SACK options, or vice versa.

The capture-bad-site2 trace seems well-formed, but seems to be taken
on the receiver side, which makes it difficult to interpret exactly
what is going wrong on the sending side.

Would you be able to reproduce the capture-bad-site2 case but take a
sender-side tcpdump trace?

Thanks!
neal
