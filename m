From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: large packet loss take2 2.6.31.x
Date: Tue, 24 Nov 2009 11:19:46 +0000
Message-ID: <20091124111946.GA7883@ff.dom.local>
References: <81bfc67a0911232217n41b9ac02w3b7770b789e5d209@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Frans Pop <elendil@planet.nl>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Caleb Cushing <xenoterracide@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <81bfc67a0911232217n41b9ac02w3b7770b789e5d209@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Nov 24, 2009 at 01:17:09AM -0500, Caleb Cushing wrote:
> > Btw, currently I don't consider this dropping means there has to be
> > a bug. It could be otherwise - a feature... e.g. when a new kernel
> > can transmit faster (then dropping in some other, slower place can
> > happen).
> 
> um... where would it be dropping that we wouldn't have a bug? I mean
> sure faster is great... but if it makes my network not work right...

E.g. if it were dropped because of a queue overflow (but it doesn't
seem to be the case, at least at your box) or because of memory
problems while handling a lot of traffic.

> 
> I've added all (I think) information you've asked for to the bug
> http://bugzilla.kernel.org/show_bug.cgi?id=13835 except for ethtool
> and netstat on the router side. ethtool complains about not having
> driver or capability (maybe because it's a 2.4 kernel?) and the
> version of netstat doesn't support -s. I disabled everything that I
> can think of that would send/receive packets before doing the test
> client side, except dhcp/dns windows box's were probably sending some
> broadcasts too. but the traffic should be pretty low. I did remember
> to set the txqueuelen didn't seem to make a difference

Alas it's not all information I asked. E.g. "netstat -s before faulty
kernel" and "netstat -s after faulty kernel" seem to be the same file:
netstat_after.slave4.log.gz. Anyway, since there are problems with
getting stats from the router we still can't compare them, or check
for the dropped stats. (Btw, could you check for /proc/net/softnet_stat
yet?)

So, it might be the kernel problem you reported, but there is not
enough data to prove it. Then my proposal is to try to repeat this
problem in more "testing friendly" conditions - preferably against
some other, more up-to-date linux box, if possible?

> only error in dmesg I see is
> 
> e1000e 0000:00:19.0: pci_enable_pcie_error_reporting failed 0xfffffffb

I added e1000e maintainers to CC to have a look at this warning.

Jarek P.

------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
