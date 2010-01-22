From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH v2 0/3] e1000e, igb,
 ixgbe: add registers etc. printout code just before resetting
 adapters
Date: Fri, 22 Jan 2010 13:54:11 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1001221345580.6104@jbrandeb-desk1.amr.corp.intel.com>
References: <4B593B74.2020601@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Koki Sanagi <sanagi.koki@jp.fujitsu.com>, e1000-devel@lists.sourceforge.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>,
	"chavey@google.com" <chavey@google.com>, "Ronciak,
	John" <john.ronciak@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>,
	"David S. Miller" <davem@davemloft.net>
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4B593B74.2020601@jp.fujitsu.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, 21 Jan 2010, Taku Izumi wrote:
> This patchset is the update version of "register etc. printout code" patch. (sorry
> for late reply)
> The old one is http://marc.info/?l=linux-netdev&m=126286127208276&w=2
> 
> v1 -> v2:
>  - replaced hexdump() with print_hex_dump()
>  - changed the register printout inplementation (for-switch-case -> data-driven-table)
> 
> However the default value of "dump_flag" is not changed (still 1).
> The reason I didn't change is
>  - I think HW index (TDH,TDT..) and SW index (NTC,NTU) are at least necessary
>  - the amount of default output is not so large (see bellow)
>  - the adapter resetting problem doesn't happen frequently

Taku, thanks for these, we are talking the patches over and reviewing 
them.  While I agree with the idea of these patches is good, I still don't 
agree with the default being enabled.  Usually if someone is getting tx 
hangs they are repeatable and we can work with them to get the debug 
turned on.  I DO think it is useful to have the feature available by 
default but NOT enabled.

If we wanted to enable something by default it might be useful to print 
something that actually draws some conclusions from known failure modes, 
like if TDH!=TDT after some amount of time.  I think one or two lines 
maximum for default printing.

If you're working in this area I had an idea.  I had wanted to be able to 
print the large amount of ring information (especially in the ixgbe case 
with many rings) to the ftrace buffers in order to not overrun the syslog 
daemon.  Not sure if you're interested in more new features, it certainly 
is separate but related to this patch. 

------------------------------------------------------------------------------
Throughout its 18-year history, RSA Conference consistently attracts the
world's best and brightest in the field, creating opportunities for Conference
attendees to learn about information security's most important issues through
interactions with peers, luminaries and emerging and established companies.
http://p.sf.net/sfu/rsaconf-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
