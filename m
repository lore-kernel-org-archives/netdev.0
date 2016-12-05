From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [ovs-dev] [PATCH net-next] net: remove abuse of VLAN DEI/CFI bit
Date: Mon, 5 Dec 2016 18:24:36 +0100
Message-ID: <20161205172436.cpxohof6rggxid74@rere.qmqm.pl>
References: <cfa1f2efae2217b50cbefccbf9ba7f0d24a23c63.1480755768.git.mirq-linux@rere.qmqm.pl>
 <20161203232730.GT3129@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
        bridge@lists.linux-foundation.org
To: Ben Pfaff <blp@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:38796 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751677AbcLERYk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 12:24:40 -0500
Content-Disposition: inline
In-Reply-To: <20161203232730.GT3129@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 03, 2016 at 03:27:30PM -0800, Ben Pfaff wrote:
> On Sat, Dec 03, 2016 at 10:22:28AM +0100, Micha³ Miros³aw wrote:
> > This All-in-one patch removes abuse of VLAN CFI bit, so it can be passed
> > intact through linux networking stack.
> > 
> > Signed-off-by: Micha³ Miros³aw <michal.miroslaw@atendesoftware.pl>
> > ---
> > 
> > Dear NetDevs
> > 
> > I guess this needs to be split to the prep..convert[]..finish sequence,
> > but if you like it as is, then it's ready.
> > 
> > The biggest question is if the modified interface and vlan_present
> > is the way to go. This can be changed to use vlan_proto != 0 instead
> > of an extra flag bit.
> > 
> > As I can't test most of the driver changes, please look at them carefully.
> > OVS and bridge eyes are especially welcome.
> 
> This appears to change the established Open vSwitch userspace API.  You
> can see that simply from the way that it changes the documentation for
> the userspace API.  If I'm right about that, then this change will break
> all userspace programs that use the Open vSwitch kernel module,
> including Open vSwitch itself.

If I understood the code correctly, it does change expected meaning for
the (unlikely?) case of header truncated just before the VLAN TCI - it will
be impossible to differentiate this case from the VLAN TCI == 0.

I guess this is a problem with OVS API, because it doesn't directly show
the "missing" state of elements, but relies on an "invalid" value.

I can probably change the code to mask this change in the OVS code (by keeping
the CFI/DEI bit unusable). This somehow feels wrong, though.

Best Regards,
Micha³ Miros³aw
