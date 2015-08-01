From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 1/9] openvswitch: Scrub packet in
 ovs_vport_receive()
Date: Sat, 1 Aug 2015 21:17:41 +0200
Message-ID: <20150801191741.GA13837@pox.localdomain>
References: <1438279963-29563-1-git-send-email-joestringer@nicira.com>
 <1438279963-29563-2-git-send-email-joestringer@nicira.com>
 <1438353294.20479.7.camel@redhat.com>
 <CANr6G5zsh2DUDBrZpQBpFO_GggvPa4ztdwDxRQuByzwU-S-FUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Justin Pettit <jpettit@nicira.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Florian Westphal <fwestpha@redhat.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:33036 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbbHATRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Aug 2015 15:17:45 -0400
Received: by wicmv11 with SMTP id mv11so92218053wic.0
        for <netdev@vger.kernel.org>; Sat, 01 Aug 2015 12:17:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CANr6G5zsh2DUDBrZpQBpFO_GggvPa4ztdwDxRQuByzwU-S-FUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/31/15 at 10:51am, Joe Stringer wrote:
> On 31 July 2015 at 07:34, Hannes Frederic Sowa <hannes@redhat.com> wrote:
> > In general, this shouldn't be necessary as the packet should already be
> > scrubbed before they arrive here.
> >
> > Could you maybe add a WARN_ON and check how those skbs with conntrack
> > data traverse the stack? I also didn't understand why make it dependent
> > on the socket.
> 
> OK, sure. One case I could think of is with an OVS internal port in
> another namespace, directly attached to the bridge. I'll have a play
> around with WARN_ON and see if I can come up with something more
> trimmed down.

The OVS internal port will definitely pass through an unscrubbed
packet across namespaces. I think the proper thing to do would be
to scrub but conditionally keep metadata.
