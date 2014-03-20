From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: i217-LM boot wreckage
Date: Thu, 20 Mar 2014 14:45:19 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1403201431580.18573@ionos.tec.linutronix.de>
References: <alpine.DEB.2.02.1403201332400.18573@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.DEB.2.02.1403201332400.18573@ionos.tec.linutronix.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, 20 Mar 2014, Thomas Gleixner wrote:
> So it looks like the BIOS is setting something up, when the cable is
> plugged at power on time, which is not visible through our debug
> output.

Some more info:

I prevented e1000e from being autoloaded and booted with the cable
unplugged.

T1:
  Plug cable 
  modprobe e1000e	-> Works

T2:
  modprobe e1000e
  plug cable		-> Works not

  rmmod e1000e
  modprobe e1000e	-> works not

  unplug cable
  rmmod e1000e
  modprobe e1000e	-> works

  rmmod e1000e
  unplug cable     
  modprobe e1000e
  plug cable		-> Works not

  rmmod e1000e
  unplug cable     
  plug cable
  modprobe e1000e	-> Works not

So if the module is loaded w/o the cable plugged it does not work. If
I unplug before unloading the module and then plug in before loading
the module again it works again.

Thanks,

	tglx


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
