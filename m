From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] openvswitch: Provide OVS_DP_ATTR_UPCALL_PID in
 datapath messages
Date: Wed, 3 Apr 2013 08:33:56 +0100
Message-ID: <20130403073356.GA6402@casper.infradead.org>
References: <e7d0e105e879fb78ff3e5628147e41d52fb0cddd.1364941614.git.tgraf@suug.ch>
 <CAEP_g=_5+1ZjiXEMCTSXE2Rt6HNkfFx1uR3KNCzwitJrLQYesg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56820 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760479Ab3DCHeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 03:34:00 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=_5+1ZjiXEMCTSXE2Rt6HNkfFx1uR3KNCzwitJrLQYesg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/02/13 at 04:30pm, Jesse Gross wrote:
> Can you describe the race condition some more?  The kernel doesn't
> change the port ID on its own so even needing to request the value
> seems rare.

The upcall nlport is changeable with OVS_VPORT_CMD_SET and may
be received between the OVS_DP_CMD_GET and OVS_VPORT_CMD_GET.

> Assigning the local ports upcall PID through datapath creation is
> really somewhat of a hack since it's port state.  I don't disagree
> that it's somewhat asymmetric now but it seems better to move away
> from the current model if possible.

Would you suggest to wait with local vport creation if no upcall
nlport is provided and let new user space binaries create the local
port explicitly?

We can't get rid of the attribute in datapath messages w/o breaking
ABI but we could make its use optional I guess.
