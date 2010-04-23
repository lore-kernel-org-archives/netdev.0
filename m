From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: eSwitch management
Date: Fri, 23 Apr 2010 14:42:12 +0200
Message-ID: <201004231442.12355.arnd@arndb.de>
References: <C7F64614.2ADDF%scofeldm@cisco.com> <DD92D5A8-1ECC-4440-BE81-ABDCC6847021@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <scofeldm@cisco.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"chrisw@redhat.com" <chrisw@redhat.com>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Amit Salecha <amit.salecha@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:59457 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757145Ab0DWMmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 08:42:18 -0400
In-Reply-To: <DD92D5A8-1ECC-4440-BE81-ABDCC6847021@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 23 April 2010, Anirban Chakraborty wrote:
> On Apr 22, 2010, at 6:29 PM, Scott Feldman wrote:
> > On 4/22/10 5:47 PM, "Scott Feldman" <scofeldm@cisco.com> wrote:
> >> 
> >> Are any of these settings covered in DCB?  (net/dcb/dcbnl.c).  Maybe you can
> >> get a start there?  Not sure not knowing your device requirements.
> > 
> > Or maybe the RTM_SETLINK IFLA_VF_* ops in include/linux/if_link.h?  Those
> > seem like what you're looking for.  I'm looking at moving iovnl here as well
> > for port-profile.
> 
> It looks like ifla_vf_info does contain most of the data set. But if I use it, what
> NETLINK protocol family should I use in my driver to receive netlink messages? Do I
> need to create a private protocol family?

Your driver should implement the ndo_set_vf_*/ndo_get_vf_* callbacks, not
implement the netlink protocol itself. If there is anything missing in the
existing callbacks that you require for the operation of your driver, you
should send patches to extend the implementation in net/core/rtnetlink.c.

	Arnd
