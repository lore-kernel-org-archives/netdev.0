From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: Fix the behavior of ethtool when ONBOOT=no
Date: Wed, 24 Jun 2009 09:59:20 -0700
Message-ID: <1245862760.12000.507.camel@nseg_linux_HP1.broadcom.com>
References: <4A41961B.2090206@miraclelinux.com>
 <4A4257B8.2090105@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Naohiro Ooiwa" <nooiwa@miraclelinux.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1394 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754720AbZFXRKA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jun 2009 13:10:00 -0400
In-Reply-To: <4A4257B8.2090105@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2009-06-24 at 09:43 -0700, Rick Jones wrote:
> Naohiro Ooiwa wrote:
> > Hi Michael
> > 
> > I found a little bug.
> > 
> > When configure in ifcfg-eth* is ONBOOT=no,
> > the behavior of ethtool command is wrong.
> > 
> >     # grep ONBOOT /etc/sysconfig/network-scripts/ifcfg-eth2
> >     ONBOOT=no
> >     # ethtool eth2 | tail -n1
> >             Link detected: yes
> > 
> > I think "Link detected" should be "no".
> 
> Why?  Sure, there is no IP on the link, but does that mean the link is 
> otherwise unusable?  Is ethtool only about IP status?
> 

Once the device is closed, we no longer keep track of the link state and
no longer have register access to determine the link state.  So we
assume it is down.  In reality, it may still be up if WoL is enabled or
management firmware is running, but the driver can no longer keep track
of it.  If we have to assume one or the other, I think it is more
correct to assume it is down.


