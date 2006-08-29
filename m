From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: Re: e1000 and 802.1ad/stacked vlan tagging
Date: Tue, 29 Aug 2006 12:58:21 +0200
Message-ID: <20060829125821.b953a646.skraw@ithnet.com>
References: <36D9DB17C6DE9E40B059440DB8D95F52866B22@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sf.net, netdev@vger.kernel.org, w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-a01.ithnet.com ([217.64.83.96]:23183 "HELO ithnet.com")
	by vger.kernel.org with SMTP id S932285AbWH2K63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 06:58:29 -0400
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52866B22@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 28 Aug 2006 13:53:36 -0700
"Brandeburg, Jesse" <jesse.brandeburg@intel.com> wrote:

> > I tried enlarging both real-device and first vlan interface mtu but
> > that does not work out. I really thought that the visible device
> > setting of mtu=1500 should have worked out and that the driver (or
> > some code in between) should have corrected the allowed frame size to
> > reflect the actual setup, not? 
> 
> unfortunately I believe that your hardware MTU on the base interface
> MUST be adjusted in order to do stacked vlans because the vlan code
> doesn't fragment packets, it just inserts tags.  The e1000 hardware is
> capable of inserting/stripping 1 level of tags without dropping overlong
> frames, but cannot seamlessly handle 1+n levels of inserted tags.
> Transmit, we don't care how long the frames are that are given to us
> (the driver doesn't enforce MTU on transmit) but on receive we have
> limited space so it is important that each frame fit into the allocated
> buffer (including CRC).
> 
> Please try MTU 1508 on eth0 (base interface only), as that configuration
> worked for me.

Hello Jesse,

I can confirm that the setup seems to work if enlarging the hw if mtu to 1508.
This is good.
Nevertheless I think that the receive buffer size of a physical device should
always be MAX(all virtual device mtu + tags and the like), you know what I
mean.
If I enlarge the basic mtu this may or may not have drawbacks concerning the
traffic routed directly via this interface.
Obviously the setup is somehow not consistent, as everything works well
without tuning mtus as long as you use only 1 tag. I always thought that the
driver uses at least hard_header_len + mtu as buffer size which should be
correct even in stacked setup. Only this information doesn't make it to the
driver level, right?

-- 
Regards,
Stephan von Krawczynski

