From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] openvswitch: correctly fragment packet with
 mpls headers
Date: Tue, 4 Oct 2016 11:28:04 +0200
Message-ID: <20161004112804.04f25140@griffin>
References: <b0cb6efc9bfda8381af880f10fa6b3447f7d3d5d.1475512190.git.jbenc@redhat.com>
        <CAOrHB_Dh=OPUTbbN7QYo9Nz4cV99-k_fT4z7jSOEcnFEDKXQEg@mail.gmail.com>
        <20161004102458.1241605f@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47234 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751711AbcJDJ2I (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Oct 2016 05:28:08 -0400
In-Reply-To: <20161004102458.1241605f@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 4 Oct 2016 10:24:58 +0200, Jiri Benc wrote:
> On Mon, 3 Oct 2016 11:04:46 -0700, Pravin Shelar wrote:
> > This is not correct way to detect MPLS packet. inner_protocol can be
> > set by any tunnel device for using tunnel offloads. So this would
> > break the fragmentation for encapsulated packets.
> 
> You're right, stupid me.

Actually, too little caffeine in the morning. I actually did consider
this and I believe my patch is correct. It doesn't matter what the
encapsulation is, we want to fragment the *inner* packet. And this is
exactly what this patch does.

Besides, the only case is MPLS anyway. I'm not aware of any code path
that could lead us to here, set inner protocol and not be MPLS. But
even if it is, it should work, provided the encapsulation header is
identical for all fragments and smaller than MAX_L2_LEN.

 Jiri
