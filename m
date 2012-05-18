From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH] e1000: Reset rx ring index on receive
	overrun
Date: Thu, 17 May 2012 17:26:45 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.1205171718160.7900@jbrandeb-mobl2.amr.corp.intel.com>
References: <20120517230140.GZ683@type.famille.thibault.fr>
	<061C8A8601E8EE4CA8D8FD6990CEA891188439E0@ORSMSX102.amr.corp.intel.com>
	<20120517232821.GJ683@type.famille.thibault.fr>
	<20120517233124.GK683@type.famille.thibault.fr>
	<alpine.WNT.2.00.1205171702590.7900@jbrandeb-mobl2.amr.corp.intel.com>
	<20120518001202.GN683@type.famille.thibault.fr>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1459309-17496-1337300807=:7900"
Cc: Jiri Pirko <jpirko@redhat.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	Dean Nelson <dnelson@redhat.com>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, "Ronciak,
	John" <john.ronciak@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Samuel Thibault <samuel.thibault@ens-lyon.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20120518001202.GN683@type.famille.thibault.fr>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--1459309-17496-1337300807=:7900
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT



On Thu, 17 May 2012, Samuel Thibault wrote:
> Brandeburg, Jesse, le Thu 17 May 2012 17:04:04 -0700, a écrit :
> > > BTW, it also happens easily when request_irq takes some time to
> > > complete: since we enable E1000_TCTL_EN before that, the card can have
> > > time to fill the ring before irqs are processed.
> > 
> > I think there may well be a bug in the implementation in kvm.  The 
> > hardware doesn't have this bug.
> 
> How does it avoid filling the ring?  What is the purpose of the RXO flag
> if it does avoid them?

RXO is only used to let the driver know "information" that the rx fifo is 
overflowing.  As it turns out the flag isn't very useful and none of our 
drivers currently use it for anything.

If the hardware fills all the available receive *descriptors* then the 
hardware's RDH (head) register will advance all the way to the RDT (tail) 
value. The tail always points one past the rx descriptors available to 
hardware to use.  RDH==RDT means there are no software provided 
descriptors in the ring available to be used by the hardware.  Our drivers 
typically allow for 1-2 descriptors to be unused in the ring to help avoid 
any confusion.

Hope this helps,
 Jesse
--1459309-17496-1337300807=:7900
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
--1459309-17496-1337300807=:7900
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--1459309-17496-1337300807=:7900--
