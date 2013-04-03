From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: Provide OVS_DP_ATTR_UPCALL_PID in
 datapath messages
Date: Wed, 3 Apr 2013 13:17:28 -0700
Message-ID: <CAEP_g=-Q=MtTWTC0sO1B27ZBszHm3Tv5Bc5gRCt2JEZrA5vM9g@mail.gmail.com>
References: <e7d0e105e879fb78ff3e5628147e41d52fb0cddd.1364941614.git.tgraf@suug.ch>
 <CAEP_g=_5+1ZjiXEMCTSXE2Rt6HNkfFx1uR3KNCzwitJrLQYesg@mail.gmail.com> <20130403073356.GA6402@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog135.obsmtp.com ([74.125.149.84]:54905 "HELO
	na3sys009aog135.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932462Ab3DCURu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 16:17:50 -0400
Received: by mail-ob0-f197.google.com with SMTP id ef5so10142649obb.4
        for <netdev@vger.kernel.org>; Wed, 03 Apr 2013 13:17:49 -0700 (PDT)
In-Reply-To: <20130403073356.GA6402@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 3, 2013 at 12:33 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 04/02/13 at 04:30pm, Jesse Gross wrote:
>> Can you describe the race condition some more?  The kernel doesn't
>> change the port ID on its own so even needing to request the value
>> seems rare.
>
> The upcall nlport is changeable with OVS_VPORT_CMD_SET and may
> be received between the OVS_DP_CMD_GET and OVS_VPORT_CMD_GET.
>
>> Assigning the local ports upcall PID through datapath creation is
>> really somewhat of a hack since it's port state.  I don't disagree
>> that it's somewhat asymmetric now but it seems better to move away
>> from the current model if possible.
>
> Would you suggest to wait with local vport creation if no upcall
> nlport is provided and let new user space binaries create the local
> port explicitly?
>
> We can't get rid of the attribute in datapath messages w/o breaking
> ABI but we could make its use optional I guess.

We have to keep the local port as part of datapath creation since it
is used as an identifier for the datapath itself.  However, you could
probably achieve the same result by using a port ID of zero for the
local port, which will prevent it from doing upcalls.  You could then
set it to a real value when you want to "create" it (this is actually
what OVS userspace does).  I think this is probably about as close to
removing it as we can get.
