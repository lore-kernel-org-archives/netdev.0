From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] core: Untag packets after rx_handler has run.
Date: Thu, 4 Sep 2014 13:43:16 -0700
Message-ID: <20140904204314.GA16612@its-macbook-pro.plumgrid.com>
References: <1409856043-21840-1-git-send-email-vyasevic@redhat.com>
 <20140904190524.GA1938@nanopsycho.lan>
 <5408BD7C.7030805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	Vladislav Yasevich <vyasevic@redhat.com>,
	Florian Zumbiehl <florz@florz.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Matthew Rosato <mjrosato@linux.vnet.ibm.com>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:38423 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754933AbaIDUnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 16:43:20 -0400
Received: by mail-pa0-f54.google.com with SMTP id fb1so20776712pad.13
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 13:43:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5408BD7C.7030805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 04, 2014 at 03:29:00PM -0400, Vlad Yasevich wrote:
> > nack. This will definitelly break several stacked setups.
> 
> Which ones?  The only thing I can see that would behave differently
> is something like:
> 
>     vlan0      bridge0
>      |           |
>      +-------- eth0
> 
> In this case, the old code would give an untagged packet to the bridge
> and the new code would give a tagged packet.
> 
> This set-up is a bit ambiguous.  Remove the vlan, and bridge gets a tagged
> traffic even though the vlan has no relationship to the bridge.
> 
> I've tested a couple of different stacked setups and they all seem to work.

2nd nack.
It will break user space, including our setup that has:
 vlanX     OVS
   |        |
   +------ eth0

vlan device has IP assigned and all tagged traffic goes through the stack
and into control plane process. ovs datapath keeps managing eth0 with
all other vlans.
