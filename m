From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net v3] ipv4: allow local fragmentation in
 ip_finish_output_gso()
Date: Fri, 4 Nov 2016 11:40:14 +0200
Message-ID: <20161104114014.3dbb8684@halley>
References: <1478118977-19608-1-git-send-email-lrichard@redhat.com>
        <20161103222751.5ae120ed@halley>
        <1769078966.96766888.1478207154311.JavaMail.zimbra@redhat.com>
        <ce29c141-65d1-c1b2-dc45-a9752fb614d8@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Lance Richardson <lrichard@redhat.com>, fw@strlen.de,
        netdev@vger.kernel.org, jtluka@redhat.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38154 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753628AbcKDJkS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 05:40:18 -0400
Received: by mail-wm0-f51.google.com with SMTP id n67so37743780wme.1
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2016 02:40:17 -0700 (PDT)
In-Reply-To: <ce29c141-65d1-c1b2-dc45-a9752fb614d8@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 3 Nov 2016 22:34:34 +0100 Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> Correct, but we should maybe redefine the code a bit. From my
> understanding we can now create an ICMP storm in case every fragment gets.

Yes, you are right.

Each segment gets into ip_fragment, and due to outer DF being set,
ICMP_FRAG_NEEDED is sent per segment.

BTW, suppose GRO is off, and sender actually did send a burst of
(non-gso) packets with outer DF set, and each was tunnel encapsulated,
resulting in oversized frames.

Would'nt the stack just send the ICMP_FRAG_NEEDED per encapsulated
frame?

If so, then the GRO behaviour is aligned, and there's nothing to fix.

Best,
Shmulik
