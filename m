From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: Provide OVS_DP_ATTR_UPCALL_PID in
 datapath messages
Date: Tue, 2 Apr 2013 16:30:43 -0700
Message-ID: <CAEP_g=_5+1ZjiXEMCTSXE2Rt6HNkfFx1uR3KNCzwitJrLQYesg@mail.gmail.com>
References: <e7d0e105e879fb78ff3e5628147e41d52fb0cddd.1364941614.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog122.obsmtp.com ([74.125.149.147]:40579 "HELO
	na3sys009aog122.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750957Ab3DBXbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 19:31:05 -0400
Received: by mail-ia0-f198.google.com with SMTP id f27so3055781iae.1
        for <netdev@vger.kernel.org>; Tue, 02 Apr 2013 16:31:03 -0700 (PDT)
In-Reply-To: <e7d0e105e879fb78ff3e5628147e41d52fb0cddd.1364941614.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 2, 2013 at 3:28 PM, Thomas Graf <tgraf@suug.ch> wrote:
> The upcall port configured when adding a new datapath is currently
> only provided to user space as part of the vport message. Therefore
> user space has to request two separate messages which is prone to
> race conditions.
>
> Provide the upcall port of the local port (0) of a data path in the
> datapath message to gain symmetry between the SET and GET command.
>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Can you describe the race condition some more?  The kernel doesn't
change the port ID on its own so even needing to request the value
seems rare.

Assigning the local ports upcall PID through datapath creation is
really somewhat of a hack since it's port state.  I don't disagree
that it's somewhat asymmetric now but it seems better to move away
from the current model if possible.
