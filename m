From: Ben Pfaff <blp@ovn.org>
Subject: Re: [ovs-dev] [PATCH net-next] net: remove abuse of VLAN DEI/CFI bit
Date: Sat, 3 Dec 2016 15:27:30 -0800
Message-ID: <20161203232730.GT3129@ovn.org>
References: <cfa1f2efae2217b50cbefccbf9ba7f0d24a23c63.1480755768.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
        "open list:OPENVSWITCH" <dev@openvswitch.org>,
        "moderated list:ETHERNET BRIDGE" <bridge@lists.linux-foundation.org>
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:42639 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751396AbcLCX1i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 18:27:38 -0500
Content-Disposition: inline
In-Reply-To: <cfa1f2efae2217b50cbefccbf9ba7f0d24a23c63.1480755768.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 03, 2016 at 10:22:28AM +0100, Michał Mirosław wrote:
> This All-in-one patch removes abuse of VLAN CFI bit, so it can be passed
> intact through linux networking stack.
> 
> Signed-off-by: Michał Mirosław <michal.miroslaw@atendesoftware.pl>
> ---
> 
> Dear NetDevs
> 
> I guess this needs to be split to the prep..convert[]..finish sequence,
> but if you like it as is, then it's ready.
> 
> The biggest question is if the modified interface and vlan_present
> is the way to go. This can be changed to use vlan_proto != 0 instead
> of an extra flag bit.
> 
> As I can't test most of the driver changes, please look at them carefully.
> OVS and bridge eyes are especially welcome.

This appears to change the established Open vSwitch userspace API.  You
can see that simply from the way that it changes the documentation for
the userspace API.  If I'm right about that, then this change will break
all userspace programs that use the Open vSwitch kernel module,
including Open vSwitch itself.
