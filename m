From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH] net-packet: tx timestamping on tpacket ring
Date: Sat, 13 Apr 2013 20:04:42 -0400
Message-ID: <CA+FuTScq=jjMddio=CgzS=mbqDEtg8NHhi8nx+jK0DutRvLLeA@mail.gmail.com>
References: <CA+FuTSezggEb7znDYMf8vWU7JmWLP59AVPkaTvNaAwJoNcqk9A@mail.gmail.com>
 <1365879412-9541-1-git-send-email-willemb@google.com> <5169D9C8.8010504@redhat.com>
 <20130413.184727.1419644906707693070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Paul Chavent <paul.chavent@onera.fr>,
	Richard Cochran <richardcochran@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	daniel.borkmann@tik.ee.ethz.ch, xemul@parallels.com,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:36000 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753678Ab3DNAFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Apr 2013 20:05:14 -0400
Received: by mail-ia0-f174.google.com with SMTP id o25so582288iad.19
        for <netdev@vger.kernel.org>; Sat, 13 Apr 2013 17:05:14 -0700 (PDT)
In-Reply-To: <20130413.184727.1419644906707693070.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 13, 2013 at 6:47 PM, David Miller <davem@davemloft.net> wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Sun, 14 Apr 2013 00:18:48 +0200
>
>>> +            flush_dcache_page(pgv_to_page(&h1->tp_sec));
>>> +            flush_dcache_page(pgv_to_page(&h1->tp_usec));
>>
>> Hmm, not sure, but could we also flush the dcache only once?
>
> Indeed, I truly hope that headers never straddle pages.

I should have checked the alignment restrictions on frames. Frames
must be a multiple of 16 B as well as larger than the header (obviously),
so this can indeed never happen.
