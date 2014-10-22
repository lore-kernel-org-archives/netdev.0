From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next] tcp: Add TCP_FREEZE socket option
Date: Wed, 22 Oct 2014 09:56:34 -0700
Message-ID: <CAHA+R7OTmmeUf=_LaN1_isL1ZKiqcS0pYE0eKpRbPhaPeX-2jQ@mail.gmail.com>
References: <1413992196-4891-1-git-send-email-kristian.evensen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:35114 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753694AbaJVQ4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 12:56:37 -0400
Received: by mail-qc0-f181.google.com with SMTP id r5so2980566qcx.40
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 09:56:34 -0700 (PDT)
In-Reply-To: <1413992196-4891-1-git-send-email-kristian.evensen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 22, 2014 at 8:36 AM, Kristian Evensen
<kristian.evensen@gmail.com> wrote:
> From: Kristian Evensen <kristian.evensen@gmail.com>
>
> This patch introduces support for Freeze-TCP [1].
>
> Devices that are mobile frequently experience temporary disconnects, for example
> due to signal fading or a technology change. These changes can last for a
> substantial amount of time (>10 seconds), potentially causing multiple RTOs to
> expire and the sender to enter slow start. Even though a device has
> reconnected, it can take a long time for the TCP connection to recover.
>
> Operators of mobile broadband networks mitigate this issue by placing TCP
> splitters at the edge of their networks. However, the splitters typically only
> operate on some ports (mostly only port 80) and violate the end-to-end
> principle. The operator's TCP splitter receives a notification when a temporary
> disconnect occurs and starts sending Zero Window Announcements (ZWA) to the
> remote part of the connection. When a devices regains connectivity, the window
> is reopened.

At least split TCP is transparent to applications, while your approach is not.
I don't understand why you said it typically operates on some ports, since
TCP is stateful.

BTW, AFAIK Linux doesn't support split TCP.
