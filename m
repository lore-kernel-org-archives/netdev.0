From: David Kimdon <david.kimdon@devicescape.com>
Subject: Re: [patch] d80211: remove sub-interface mac address policy
Date: Thu, 21 Sep 2006 14:10:57 -0700
Message-ID: <20060921211057.GA22875@devicescape.com>
References: <20060914143321.GA1962@devicescape.com> <20060921200939.1cab8c1c@logostar.upir.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-87.dex002.intermedia.net ([64.78.20.224]:47156 "EHLO
	dhost002-87.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1750862AbWIUVS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 17:18:56 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060921200939.1cab8c1c@logostar.upir.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 21, 2006 at 08:09:39PM +0200, Jiri Benc wrote:
> On Thu, 14 Sep 2006 07:33:21 -0700, David Kimdon wrote:
> > Wireless vlan interfaces need to have the same mac address as
> > other sub interfaces.  Rather than complicate the kernel here by
> > adding yet another case where uniqueness is not required, remove
> > the check on mac address uniqueness altogether.
> > 
> > We should not implement a mac address allocation policy here.  It
> > is difficult to get it right in all cases and does not belong in
> > the kernel.  It is better to leave this to be implemented as a
> > userspace policy.
> 
> I disagree. This is not about policy, this is about prevention of
> accidental violation of IEEE 802.11. The only effect of this patch would
> be forcing drivers to do that check themselves thus duplicating code.

That is fine, I don't feel strongly, I will cook up a patch that fixes
the check for vlan interfaces.

> What is the purpose of "wireless vlans"?

We use wireless vlans to isolate stations to separate multicast
domains within the same bss based on the input of a radius server.  A
stations is bound to a particular wireless vlan interface, all
stations on that wireless vlan share broadcast keys, and the wireless
vlan interface can be bridged to a particular wired vlan.

> Is it something Atheros-specific?
no, it is chip driver agnostic.

> Is it documented somewhere?  Or is it in some of IEEE 802.11
> standards and I just overlooked it? (In that case I would be more
> than happy to review the whole stack and fix it.) Could you send us
> some pointers?

Take a look at http://www.ietf.org/rfc/rfc3580.txt section 3.31.
Tunnel Attributes.  That is what we are processing at a high level to
get vlan assignment.  FWIW, we have code on its way to hostapd cvs
that uses wireless vlans which will show more details of this
particular implementation.

David
