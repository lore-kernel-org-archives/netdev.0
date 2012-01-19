From: David Lamparter <equinox@diac24.net>
Subject: Re: ixgbe: Unsupported SFP+ modules on 10Gbit/s
 X520-DA2 NIC?
Date: Thu, 19 Jan 2012 12:50:54 +0100
Message-ID: <20120119115054.GJ2262734@jupiter.n2.diac24.net>
References: <1326886258.19261.25.camel@probook>
	<20120118091351.000052fc@unknown> <m3d3ag7ki8.fsf@ursa.amorsen.dk>
	<9B4A1B1917080E46B64F07F2989DADD621FC38@ORSMSX102.amr.corp.intel.com>
	<4F174A6F.8050002@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@comx.dk>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>,
	Benny Amorsen <benny+usenet@amorsen.dk>
To: Ben Greear <greearb@candelatech.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <4F174A6F.8050002@candelatech.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Jan 18, 2012 at 02:40:47PM -0800, Ben Greear wrote:
> On 01/18/2012 02:21 PM, Fujinaka, Todd wrote:
> > Jesse Brandeburg<jesse.brandeburg@intel.com>  writes:
> >
> >> For X520 adapters, the documentation[1] states that which SFP+
> >> adapters are/are not supported.  Direct attach cables are also
> >> supported.
> >>
> >> [1]
> >> http://www.intel.com/support/network/adapter/pro100/sb/CS-030612.htm
> >
> > I can't believe that locked optics have now arrived on commodity hardware. I have been trying to migrate to all-Intel networking at work; that effort is certainly on hold now.
> >
> >
> > That's up to you. There's "locked" and there's "locked". I'm surprised
> > that Benny and Jesper haven't looked at the driver to see where the
> > messages come from.
> 
> As a datapoint:  We had a customer trying to use a non-supported
> SFP+ module in an 82599 NIC, and they hacked the driver to over-rule
> the exclusion.  It sort of worked for them, but never well, and never
> at any decent throughput.
> 
> Now, I have no idea if their SFP+ was decent or not, but at least in
> some cases, just over-riding the driver doesn't fix things.
> 
> It does seem like Intel could offer a module option to easily over-ride the
> SFP+ exclusion for folks that wanted to test new SFP+ modules for them,
> however.

Sorry, but the whole practice is complete and utter bullshit. And I'm
saying that as a hardware engineer.

For starters, there are only a handful manufacturers that actually make
SFPs. I don't have numbers but I'd claim Finisar, Avago and JDSU have
at least 50% of the market. (cf.
http://www.finisar.com/faq/Operational-Information:
"Who are some of the competitors in these businesses?
"Finisar competes primarily with Avago, CoAdna, JDSU, Oclaro, Opnext,
Oplink, and Sumitomo.")

(By the way, on 1G SFPs the original price is around $20, from where the
OEM sticker gets them up to $150 in bad cases [Cisco]. No idea how bad
it is with 10G.)

Also, the electrical parameters are not that hard to quantify and test.
The spec has minimum eye opening requirements, maximum jitter allowance,
etc. - if a vendor gets them wrong, they'll fail quite quickly.

Further, look at Flexoptix and their "reflash the SFP" business model.
(http://www.flexoptix.net/)

Oh and you even get the same OEM sticker on different real vendors.

Intel isn't making their own SFPs, and they're not getting SFPs with
custom tweaks on the electrical interface from SFP vendors.

You can always get a shitty transceiver if the vendor has a bad day, but
that's not gonna be bound to the OEM sticker.

(btw, bad SFPs manifest as CRC/FCS errors, not as bad throughput. If you
have bad throughput but no errors, the NIC's firmware is fucking with
you.)


-David


------------------------------------------------------------------------------
Keep Your Developer Skills Current with LearnDevNow!
The most comprehensive online learning library for Microsoft developers
is just $99.99! Visual Studio, SharePoint, SQL - plus HTML5, CSS3, MVC3,
Metro Style Apps, more. Free future releases when you subscribe now!
http://p.sf.net/sfu/learndevnow-d2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
