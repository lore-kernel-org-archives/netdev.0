From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: Question regarding MAC address configuraton with VLAN devices
Date: Wed, 8 Apr 2015 11:20:16 +0200
Message-ID: <20150408092016.GA27193@unicorn.suse.cz>
References: <31AFFC7280259C4184970ABA9AFE8B93E0930C40@avmb3.qlogic.org>
 <5523FB49.9010107@redhat.com>
 <B5657A6538887040AD3A81F1008BEC63C26107@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:45741 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751659AbbDHJUS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 05:20:18 -0400
Content-Disposition: inline
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63C26107@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 08, 2015 at 05:49:59AM +0000, Yuval Mintz wrote:
> I think there's an even simpler question here -
> Today, if you'll have a network interface with a vlan stacked on top of it
> and user calls 'ip link set ... address ...' the end result would be that the vlan
> interface retains the original MAC and push it downward [to base device].
> You can claim this is harmless, but I don't really think anyone intends this to
> happen.

If it wasn't intended, why would anyone write the code doing the sync
(and switching to promiscuous mode as a fallback)? The way I see it,
there were two options:

  (a) add upper device's address to lower device's uc list
  (b) propagate changed MAC address upwards

And the decision was to choose (a). While (b) might make some things
simpler (and others more complicated), changing the behaviour now when
people are used to it would be IMHO very unfortunate.

                                                        Michal Kubecek
