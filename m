From: Sridhar Samudrala <samudrala.sridhar@gmail.com>
Subject: Re: [Patch net-next] vxlan: revert "vxlan: Bypass encapsulation if
 the destination is local"
Date: Sun, 14 Apr 2013 21:20:40 -0700
Message-ID: <516B8018.80308@gmail.com>
References: <516641CF.4020101@us.ibm.com>  <1937058599.2214531.1365659704193.JavaMail.root@redhat.com>  <1365724799.3563.5.camel@sridhar.usor.ibm.com>  <20130412.151916.63924835658790088.davem@davemloft.net>  <516893BD.20303@us.ibm.com> <1365993080.5074.5.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mike.rapoport@ravellosystems.com
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:45399 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264Ab3DOEUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 00:20:45 -0400
Received: by mail-qc0-f182.google.com with SMTP id k19so2008108qcs.13
        for <netdev@vger.kernel.org>; Sun, 14 Apr 2013 21:20:44 -0700 (PDT)
In-Reply-To: <1365993080.5074.5.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/14/2013 7:31 PM, Cong Wang wrote:
> On Fri, 2013-04-12 at 16:07 -0700, Sridhar Samudrala wrote:
>> To address this behavior seen with veth, i had to change the if
>> condition to
>> check for rt->dst.dev->flags rather than rt->rt_flags.
> There is no specific IFF_ flag for veth, nor I think introducing one is
> a correct fix.
>
> I think we can just revert it for now, since it is not very easy to fix.
> You can, of course, send a bug-free version later. This regression
> blocks my VXLAN IPv6 support patches, by the way.
>
>
I am not suggesting adding a new IFF_ flag for veth. I was referring to the
IFF_LOOPBACKflag and it should work fine for your setup.

However, i think Mike Rapaport't patch that adds a check to test for 
multicast/
broadcast routeisa better fix. Did you try that patch?
I tried it in my setup using both vxlan/DOVE configuration between VMs 
in the
same networknamespace on 2 different bridges as well as the veth 
configuration
between 2 network namespsaces.

Could you try his patch in your configuration. I think it will work and 
if so
we should go withthat patch.

Thanks
Sridhar
