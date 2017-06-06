From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 00/16] nfp: ctrl vNIC
Date: Tue, 6 Jun 2017 08:16:10 +0200
Message-ID: <20170606061610.GA1911@nanopsycho>
References: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36099 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750881AbdFFGQO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 02:16:14 -0400
Received: by mail-wm0-f54.google.com with SMTP id 7so89384875wmo.1
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 23:16:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jun 06, 2017 at 02:01:41AM CEST, jakub.kicinski@netronome.com wrote:
>Hi!
>
>This series adds the ability to use one vNIC as a control channel
>for passing messages to and from the application firmware.  The
>implementation restructures the existing netdev vNIC code to be able
>to deal with nfp_nets with netdev pointer set to NULL.  Control vNICs
>are not visible to userspace (other than for dumping ring state), and
>since they don't have netdevs we use a tasklet for RX and simple skb 
>list for TX queuing.
>
>Due to special status of the control vNIC we have to reshuffle the
>init code a bit to make sure control vNIC will be fully brought up
>(and therefore communication with app FW can happen) before any netdev
>or port is visible to user space.
>
>FW will designate which vNIC is supposed to be used as control one
>by setting _pf%u_net_ctrl_bar symbol.  Some FWs depend on metadata
>being prepended to control message, some prefer to look at queue ID
>to decide that something is a control message.  Our implementation
>can cater to both.
>
>First two users of this code will be eBPF maps and flower offloads.

How do you actually do the configuration from the userspace? I did not
find it in the patches.

I'm not really sure that doing it using one "control netdevice" is the
correct way to go. The configuration is asic-wide, should be done by a
devlink parent handle which was introduced for that exact purpose.

Am I missing something? We need to sync in this. In mlxsw we need to do
some pre-netdev configuraton as well.

Thanks.
