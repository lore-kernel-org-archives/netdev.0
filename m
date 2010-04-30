From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next-2.6 PATCH 2/2] add ndo_set_port_profile op support for
 enic dynamic vnics
Date: Fri, 30 Apr 2010 13:34:04 -0700
Message-ID: <C8008CCC.2D21E%scofeldm@cisco.com>
References: <201004291748.38702.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<chrisw@redhat.com>, Jens Osterkamp <Jens.Osterkamp@gmx.de>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:30715 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933313Ab0D3UeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 16:34:11 -0400
In-Reply-To: <201004291748.38702.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/29/10 8:48 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:

> I believe Chris is the one that was pushing most for having a single interface
> for both VDP/LLDPAD and enic.
> While I now understand your reasons for doing it in firmware and requiring the
> kernel interface in addition to the user interface, my doubts on whether VDP
> and your protocol should be part of the same interface are increasing.
> 
> While I'm convinced that you can make it work for both now, the alternative
> to split the two may turn out to be cleaner. We'd still be able to do
> either of the two in kernel or user space. Using iproute2 syntax to describe
> this again, it would mean an interface like
> 
>    ip iov set  port-profile DEVICE [ base BASE-DEVICE ] name PORT-PROFILE
>                              [ host_uuid HOST_UUID ]
>                      [ client_name CLIENT_NAME ]
>                                       [ client_uuid CLIENT_UUID ]
>    ip iov set  vsi { associate | pre-associate | pre-associate-rr }
> BASE-DEVICE
>                                       vsi MGR:VTID:VER
>                                       mac LLADDR [ vlan VID ]
>                                       client_uuid CLIENT_UUID
> 
>    ip iov del  port_profile DEVICE      [ base BASE-DEVICE ]
>    ip iov del  vsi          BASE-DEVICE [ mac LLADDR [ vlan VID ] ]
>        [ client_uuid CLIENT_UUID ]
> 
>    ip iov show port_profile DEVICE      [ base BASE-DEVICE ]
>    ip iov show vsi          BASE-DEVICE [ mac LLADDR [ vlan VID ] ]
> [ client_uuid CLIENT_UUID ]
> 
> You would obvioulsy only implement the kernel support for the port-profile
> stuff as callbacks, because no driver yet does VDP in the kernel, but we
> should
> have a common netlink header that defines both variants.
> 
> Chris, any opinion on this interface as opposed to the combined one?
> Either one should work, but splitting it seems cleaner to me.

I haven't seen Chris's response, but it seems vger was down for awhile, so
maybe it's coming.  Assuming we go for the split design, we're still talking
about using RTM_SETLINK/RTM_GETLINK/RTM_DELLINK for these netlink msgs?  Or
are you suggesting by your cmd syntax that we return to
RTM_SETIOV/RTM_GETIOV like in the first iovnl patch?  RTM_SET/GET/DELLINK is
probably simplier, cleaner patch.

-scott

