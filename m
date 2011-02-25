From: Jesse Gross <jesse@nicira.com>
Subject: Re: TX VLAN acceleration on bridges broken in 2.6.37?
Date: Fri, 25 Feb 2011 14:53:21 -0800
Message-ID: <AANLkTinoJqWA6ffnUx2KW_83srNbo+k6r24hnNpPTGvW@mail.gmail.com>
References: <20110221232902.GA3440@x61s.reliablesolutions.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Niehusmann <jan@gondor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110221232902.GA3440@x61s.reliablesolutions.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 21, 2011 at 3:29 PM, Jan Niehusmann <jan@gondor.com> wrote:
> With the following configuration, sending vlan tagged traffic from a
> bridged interface doesn't work in 2.6.37.
> The same configuration does work with 2.6.36:
>
> - bridge br0 with physical interface eth0
> - eth0 being an e1000e device (don't know if that's important)
> - vlan interface br0.10
> - (on 2.6.37) tx vlan acceleration active on br0 (default)
>
> Networking on br0.10 doesn't work, and tcpdump on eth0 shows packets
> sent on br0.10 as untagged, instead of vlan 10 tagged.

I looked at this and wasn't able to reproduce it with either 2.6.37 or
net-next on either of my NICs (ixgbe and bnx2).  I'm guessing that it
is specific to the e1000e driver.  I know that some other Intel NICs
require vlan stripping on receive to be enabled for vlan insertion on
transmit to work.  Since this driver has not been converted over to
use the new vlan model yet, it only enables these things if a vlan is
directly configured on it.  To confirm this can you try a few things:

* Directly configure the vlan on the device instead of going through the bridge.
* Use the bridge but also configure an unused vlan device on the
physical interface.
* Double check that tcpdump with the settings that you are using shows
vlan tags in other situations.  In some cases you need to use the 'e'
flag with tcpdump in order for it show vlan tags.  If it is the
driver/NIC that is dropping the tags, tcpdump should still show them.

Thanks.
