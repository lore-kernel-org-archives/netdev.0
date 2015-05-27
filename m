From: Flavio Leitner <fbl@sysclose.org>
Subject: Re: [ovs-dev] [PATCH net] openvswitch: disable LRO unless stated
 otherwise
Date: Wed, 27 May 2015 10:24:14 -0300
Message-ID: <20150527132414.GB2502@x240.home>
References: <15f0c96df9cc152b05d8a5ff0c0059eb1f042cca.1432661690.git.jbenc@redhat.com>
 <CALnjE+o-rHrcrmbwb4n4Py5smH3M8oOS-EBCGF2Rc0-e_Y1rmQ@mail.gmail.com>
 <20150527105021.21879f6c@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pravin Shelar <pshelar@nicira.com>,
	netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@redhat.com>
To: dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender1.zohomail.com ([74.201.84.157]:24963 "EHLO
	sender163-mail.zoho.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751326AbbE0NYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 09:24:20 -0400
Content-Disposition: inline
In-Reply-To: <20150527105021.21879f6c@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 27, 2015 at 10:50:21AM +0200, Jiri Benc wrote:
> On Tue, 26 May 2015 15:03:56 -0700, Pravin Shelar wrote:
> > OVS interface for generic networking device operation looks odd. have
> > you considered adding new device ioctl to do this?
> 
> New ioctls for networking configuration are generally not allowed. The
> preferred way to configure networking is netlink. And as this is very
> much ovs specific (all other users of dev_disable_lro such as bridging
> want to do this unconditionally), ovs netlink is the correct place to
> put this to.

Exactly. Team, Bonding, bridge, and when you enable forwarding on a
networking device gets LRO automatically disabled in the kernel.

I suggest to always disable LRO in the kernel as the other examples
do until there is a real need in OVS to benefit from LRO to implement
such API change.

fbl
