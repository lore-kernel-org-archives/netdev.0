From: Ben Greear <greearb@candelatech.com>
Subject: [PATCH 0/3]  e100: Enable receiving bogus packets and saving FCS
Date: Mon, 24 Nov 2003 23:53:11 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FC30A67.2010602@candelatech.com>
References: <3FC2931B.3070903@candelatech.com>	<20031124152933.1420f6cf.davem@redhat.com>	<3FC298C9.8080302@candelatech.com> <20031124173330.096c0751.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20031124173330.096c0751.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Mon, 24 Nov 2003 15:48:25 -0800
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>So, RX-ALL can be one flag, another for RX-FCS, and the TX-CUSTOM-FCS
>>can be a separate patch altogether?
> 
> 
> That is the basic idea, yes.

Here are three patches.  These were extracted manually from my
big patchset.  Where flags are defined, I left in the pktgen receive
flag and the send-to-self flag from my larger patch set.
If this is unacceptable, I can shuffle the flags around....

rx_all_ethtool.patch is the ethtool glue to turn on/off the RX-ALL and SAVE-FCS
flags.  I have not tested any of the ethtool-ops code branches as e100 and e1000
does not appear to use it.

rx_all_headers.patch should take care of defining the flags in if.h and netdevice.h

rx_all_e100.patch converts the e100 driver to support these features.  I've
ripped out the tx-custom-fcs code, but the rx-all and save-fcs code is there.
The default behaviour is virtually identical, because while the old code
was enabling receiving a lot of bad packets when in PROMISC mode, the check
in e100_main rx code was throwing away anything that was not marked as good
anyway...

> However, one thing I want to make absolutely clear is that I do not
> want multiple ways to get the same information out of the kernel.
> We decided to build netlink into the kernel always because this means
> it is present in everyone's kernel.  And therefore, we don't need to
> add another way to obtain the same config information already
> available via netlink.  The existing cases where an ioctl() style
> call exists to obtain the same info available via netlink is merely
> for compatability with older BSD tools.  No new such things will be
> added.

Ok, I won't ask again.  I attempted to get rid of all the 'ndstats'
code from these patches.  If some is still in there, it's an accident
and I'll remove it.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
