From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ethtool_ops rev 4
Date: Fri, 01 Aug 2003 19:17:57 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2AF525.3000605@pobox.com>
References: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk>	<20030801154021.GA7696@gtf.org>	<20030801154656.GW22222@parcelfarce.linux.theplanet.co.uk>	<20030801162536.GA18574@gtf.org>	<20030801132037.3f3542ae.davem@redhat.com>	<3F2AE91D.5090705@pobox.com>	<20030801153255.204baf66.davem@redhat.com>	<3F2AF141.2010308@pobox.com> <20030801160136.3342c5cc.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: willy@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030801160136.3342c5cc.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Fri, 01 Aug 2003 19:01:21 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> 
>>A DO_ETHTOOL_OPS macro in the driver's ->do_ioctl -- intentionally not 
>>included in the kernel -- does the rest,
> 
> 
> I don't understand.
> 
> Where does this DO_ETHTOOL_OPS macro come from?  Is it defined
> by kcompat?  If so, how will drivers in vanilla 2.4.x trees end
> up with the DO_ETHTOOL_OPS define?



If one wishes to implement kcompat design ("it looks like a 2.6 
driver"), then you have two needs over and above Matthew's current 
ethtool_ops patch:  (1) naked struct deref of netdev->ethtool_ops will 
break immediately on older kernels, and (2) to avoid code duplication, 
you need to insert a call to kcompat's 
do_ethtool_handling_the_old_way... i.e. basically what 
net/core/ethtool.c does now.

Problem #1 is solved with a wrapper macro that disguises the naked 
struct deref to ->ethtool_ops.
Problem #2 is solved by adding a call to DO_ETHTOOL_OPS macro in a 
driver's ->do_ioctl handler.

So, with those two minor changes, a 2.6 driver will work on an older kernel.

To answer your question above, DO_ETHTOOL_OPS can occur one of two ways: 
  (1) my preferred approach, define a no-op DO_ETHTOOL_OPS macro 
in-kernel -- but I did not think this would get accepted, so I chose (2) 
DO_ETHTOOL_OPS exists entirely in kcompat, and people submitting kcompat 
users to mainline would simply delete the one line calling 
DO_ETHTOOL_OPS.  Solution #2 chooses to create a tiny bit more 
merge-to-mainline pain, but also keeps the mainline kernel drivers more 
clean.

	Jeff
