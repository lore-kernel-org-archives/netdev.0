From: Jan Niehusmann <jan@gondor.com>
Subject: Re: TX VLAN acceleration on bridges broken in 2.6.37?
Date: Sat, 26 Feb 2011 01:19:08 +0100
Message-ID: <20110226001908.GA10777@x61s.reliablesolutions.de>
References: <20110221232902.GA3440@x61s.reliablesolutions.de>
 <AANLkTinoJqWA6ffnUx2KW_83srNbo+k6r24hnNpPTGvW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTinoJqWA6ffnUx2KW_83srNbo+k6r24hnNpPTGvW@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 25, 2011 at 02:53:21PM -0800, Jesse Gross wrote:
> is specific to the e1000e driver.  I know that some other Intel NICs
> require vlan stripping on receive to be enabled for vlan insertion on
> transmit to work.  Since this driver has not been converted over to
> use the new vlan model yet, it only enables these things if a vlan is
> directly configured on it.  To confirm this can you try a few things:

My observations confirm your theory:

> * Directly configure the vlan on the device instead of going through the bridge.

- does work, but only if eth0 is not part of bridge (expected behaviour,
  afaik)

> * Use the bridge but also configure an unused vlan device on the
> physical interface.

- does work

> * Double check that tcpdump with the settings that you are using shows
> vlan tags in other situations.  In some cases you need to use the 'e'
> flag with tcpdump in order for it show vlan tags.  If it is the
> driver/NIC that is dropping the tags, tcpdump should still show them.

- indeed, -e is necessary to show the vlan tags. So my prior observation
  regarding tag visibility in tcpdump was wrong. The packets are still
  have a vlan tag in the non-working case. 

  (What actually is affected by the txvlan flag is the ability to filter
  for vlan tags with tcpdump.  so 'tcpdump -e -i eth0' shows the packets,
  'tcpdump -e -i eth0 vlan' only shows them with txvlan off. However,
  filtering for the vlan tag also doesn't work with the vlan interface
  on eth0.1, while the tagging actually works, as verified above.)


Jan
