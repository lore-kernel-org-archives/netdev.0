From: Stefan Rompf <srompf@isg.de>
Subject: Re: PATCH idea - netlink and link changes
Date: Sat, 12 Oct 2002 11:23:39 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3DA7EA1B.3D0430F@isg.de>
References: <3DA7035F.5080101@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Tim Hockin <thockin@sun.com>
List-Id: netdev.vger.kernel.org

Hi Tim,

> Looking for feedback on this quickie patch.  This enables netlink to
> deliver link-change events, as reported by drivers via
> netif_carrier_{on,off}.

I've taken a closer look at the approach and like it more than my own
implementation. What you are currently missing is some code to assure
that a device does not have an event queued after removal - look what my
patch does in netdev_unregister(). Patching f.e. the vlan driver to do
some netif_carrier_on/off in the stop method is a good test case. Also,
do not forget to call the network notifier chain beside emitting a
netlink message - the kernel isinterested in the event, too.

IMHO we should merge the patches, taking your one workqueue per device
approach and my usage of IFF_RUNNING as a mirror bit. What do other
netdev people think?

Cheers, Stefan
