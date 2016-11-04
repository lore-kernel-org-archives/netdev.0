From: Lance Richardson <lrichard@redhat.com>
Subject: Re: [PATCH net v3] ipv4: allow local fragmentation in
 ip_finish_output_gso()
Date: Fri, 4 Nov 2016 09:49:13 -0400 (EDT)
Message-ID: <1461381070.97911800.1478267353507.JavaMail.zimbra@redhat.com>
References: <1478118977-19608-1-git-send-email-lrichard@redhat.com> <20161103222751.5ae120ed@halley> <1769078966.96766888.1478207154311.JavaMail.zimbra@redhat.com> <ce29c141-65d1-c1b2-dc45-a9752fb614d8@stressinduktion.org> <20161104114014.3dbb8684@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>, fw@strlen.de,
        netdev@vger.kernel.org, jtluka@redhat.com
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx6-phx2.redhat.com ([209.132.183.39]:53187 "EHLO
        mx6-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933535AbcKDNt1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 09:49:27 -0400
In-Reply-To: <20161104114014.3dbb8684@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: "Shmulik Ladkani" <shmulik.ladkani@gmail.com>
> To: "Hannes Frederic Sowa" <hannes@stressinduktion.org>
> Cc: "Lance Richardson" <lrichard@redhat.com>, fw@strlen.de, netdev@vger.kernel.org, jtluka@redhat.com
> Sent: Friday, November 4, 2016 5:40:14 AM
> Subject: Re: [PATCH net v3] ipv4: allow local fragmentation in ip_finish_output_gso()
> 
> On Thu, 3 Nov 2016 22:34:34 +0100 Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > Correct, but we should maybe redefine the code a bit. From my
> > understanding we can now create an ICMP storm in case every fragment gets.
> 
> Yes, you are right.
> 
> Each segment gets into ip_fragment, and due to outer DF being set,
> ICMP_FRAG_NEEDED is sent per segment.
> 
> BTW, suppose GRO is off, and sender actually did send a burst of
> (non-gso) packets with outer DF set, and each was tunnel encapsulated,
> resulting in oversized frames.
> 
> Would'nt the stack just send the ICMP_FRAG_NEEDED per encapsulated
> frame?
> 
> If so, then the GRO behaviour is aligned, and there's nothing to fix.
> 

Agree.

> Best,
> Shmulik
> 
