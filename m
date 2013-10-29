From: Michael Dalton <mwdalton@google.com>
Subject: Re: [PATCH net-next] virtio_net: migrate mergeable rx buffers to page
 frag allocators
Date: Tue, 29 Oct 2013 12:05:27 -0700
Message-ID: <CANJ5vP+=wCrzJ3Fdg0_5ZTTT-V-fw2AXUG=EgwsUcxXO=UpMgw@mail.gmail.com>
References: <1383000258-1458-1-git-send-email-mwdalton@google.com> <CAG7+5M1VFSZciaZf+Y_yzm=aq1Z4fZ-QgACN2srnC9twOWhVWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Daniel Borkmann <dborkman@redhat.com>,
	lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>
To: Eric Northup <digitaleric@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:47518 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751612Ab3J2TFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 15:05:47 -0400
Received: by mail-ob0-f175.google.com with SMTP id wm4so360027obc.6
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 12:05:47 -0700 (PDT)
In-Reply-To: <CAG7+5M1VFSZciaZf+Y_yzm=aq1Z4fZ-QgACN2srnC9twOWhVWw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Agreed Eric, the buffer size should be increased so that we can accommodate a
MTU-sized packet + mergeable virtio net header in a single buffer. I will send
a patch to fix shortly cleaning up the #define headers as Rusty indicated and
increasing the buffer size slightly by VirtioNet header size bytes per Eric.

Jason, I'll followup with you directly - I'd like to know your exact workload
(single steam or multi-stream netperf?), VM configuration, etc, and also see if
the nit that Erichas pointed out affects your results.  It is also
worth noting that
we may want to tune the queue sizes for your benchmarks, e.g, by reducing
buffer size from 4KB to MTU-sized but keeping queue length constant, we're
implicitly decreasing the number of bytes stored in the VirtioQueue for the
VirtioNet device, so increasing the queue size may help.

Best,

Mike
