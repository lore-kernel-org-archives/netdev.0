From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ethtool_ops rev 4
Date: Fri, 01 Aug 2003 19:35:20 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2AF938.7050608@pobox.com>
References: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk>	<20030801154021.GA7696@gtf.org>	<20030801154656.GW22222@parcelfarce.linux.theplanet.co.uk>	<20030801162536.GA18574@gtf.org>	<20030801132037.3f3542ae.davem@redhat.com>	<3F2AE91D.5090705@pobox.com>	<3F2AEB33.9050506@pobox.com>	<20030801153439.4a324c36.davem@redhat.com>	<3F2AF32F.7090201@pobox.com> <20030801160857.32ebbf22.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: willy@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030801160857.32ebbf22.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Fri, 01 Aug 2003 19:09:35 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> 
>>#define SET_ETHTOOL_OPS kcompat_set_ethtool_ops
>>
>>#define DO_ETHTOOL_OPS /* duplicate net/core/ethtool.c, basically */
> 
> 
> Where does kcompat_set_ethtool_ops store the pointer if
> it does not exist in struct netdevice?


Inside an area allocated by the kcompat lib.  SET_ETHTOOL_OPS takes 
'struct net_device *' and 'struct ethtool_ops *' arguments, so it simply 
needs to create a lookup list/table somewhere.

You keep asking for code, read kcompat :)  kcompat_set_ethtool_ops has 
exactly the same task as the 2.2.x-era backcompat implementation of 
pci_{get,set}_drvdata.

The perfect back-porting/back-compat system would magically make all 
Linus-tree drivers work without any change on older kernels.  I really 
think the kcompat design is as close as you can come to that.

Here is a linux-kernel-friendly version of the kcompat design:

	"naked struct derefs hurt. otherwise, happy hacking!"

And further, experience shows that the number of naked struct derefs 
that matter is fairly small.

(Another less-common area that hurts besides naked-struct-deref is 
function return type, which is why Linus created irqreturn_t)

	Jeff
