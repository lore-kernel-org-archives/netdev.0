From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100
 rx: or s and el bits)
Date: Tue, 05 Jun 2007 10:27:19 -0700
Message-ID: <46659CF7.2070003@intel.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net>
	<46375664.8030701@roinet.com> <4638F2B2.2000103@roinet.com>
	<463BA906.30205@roinet.com>
	<85f07fc58d5ed2147d5214d0f0b4fe32@bga.com>
	<4648A9DF.6030001@roinet.com> <464D074F.20400@pobox.com>
	<464D21B6.2000208@intel.com> <464DB336.2030003@roinet.com>
	<464DB619.3070900@roinet.com> <464DC676.90504@intel.com>
	<464DCA97.3070405@roinet.com> <464DCD5E.50003@intel.com>
	<464DDE3E.9010400@roinet.com>
	<e3819b7a866b1117fd5a69e6a85e0784@bga.com>
	<4651DAC1.7050604@intel.com>
	<53c44b6f03973eb1b28f221859d3002c@bga.com>
	<465369AF.8080508@roinet.com>
	<f83441453b1233771c5bda869912aeca@bga.com>
	<4654B2E4.9010308@roinet.com>
	<039d8ee49a8dfcbff8695b19d0a1a5c4@bga.com>
	<a4fae96e1c8c7b594207bf77fcb6b38f@bga.com>
	<465C4DBE.6000205@roinet.com>
	<94c8ff9069a77568513a9a1d1e60012d@bga.com>
	<4660856E.80403@roinet.com>
	<fac4512e243d821a94e8ee7304240981@bga.com>
	<4665664D.30906@roinet.com>
	<b2809ae38545c6104771af3c3a8b2250@bga.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Scott Feldman <sfeldma@pobox.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Acker <dacker@roinet.com>
To: Milton Miller <miltonm@bga.com>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <b2809ae38545c6104771af3c3a8b2250@bga.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Milton Miller wrote:
> First, a question especially to Auke and Jeff:
> 
> Since this patch both reverts the broken change that is currently in 
> -rc and creates the fixed driver, I'm not sure I like the subject 
> stating "on ARM", although that is the feature of the rewrite, and was 
> the intent of merging the previous patch.  This is actually its a fix 
> for all systems relative to current, including those where dma is not 
> cache coherent, (unlike a simple revert).
> 
> Should we just put a comment about reverting the previous patch early 
> in the change log?

yes

> Something like this:
> 
> Fix the e100 receiver handling, supporting cache incoherent DMA.
> 
> Discard the concept of setting the S (suspend) bit with the EL bit 
> introduced in commit d52df4a35af569071fda3f4eb08e47cc7023f094.  In 
> addition to it not setting either bit, the hardware doesn't work that 
> way.
> 
> 
> Thoughts?

the same comment I made about the coding style counts for this too: I will clean 
up the patch and gladly adjust the topic, which in this case seems the right 
thing to do. I am too grateful that you guys are digging into this so deeply to 
send you back with comments on style - I'll gladly fix that up :)

> Here is the changelog portion of the latest patch (quoted), with my 
> comments thrown in:

OK, I will buffer this info and make sure this gets picked up on the final version.

this opens up another question:

We need to make sure that now that we're getting closer to 2.6.22 we don't end 
up killing e100 in it. Should we drop the current fixes in it to be on the safe 
side and aim for 2.6.23? I would hate to see an untested codepath breaking e100 
on something like ppc or mips... that will be very painful

Jeff, your thoughts on that?

Auke

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
