From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [RFC] Runtime power management on ipw2100
Date: Thu, 08 Feb 2007 17:01:46 +0800
Message-ID: <1170925306.19089.125.camel@debian.sh.intel.com>
References: <20070131075249.GA22115@srcf.ucam.org>
	<1170294425.6601.182.camel@debian.sh.intel.com>
	<20070206214407.GA5254@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ipw2100-devel@lists.sourceforge.net, linux-pm@lists.osdl.org,
	netdev@vger.kernel.org
To: Matthew Garrett <mjg59@srcf.ucam.org>
Return-path: <ipw2100-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20070206214407.GA5254@srcf.ucam.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipw2100-devel>,
	<mailto:ipw2100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ipw2100-devel>
List-Post: <mailto:ipw2100-devel@lists.sourceforge.net>
List-Help: <mailto:ipw2100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipw2100-devel>,
	<mailto:ipw2100-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ipw2100-devel-bounces@lists.sourceforge.net
Errors-To: ipw2100-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 2007-02-06 at 21:44 +0000, Matthew Garrett wrote:
> I'm reluctant to drop the IRQ because PCMCIA seems to have 
> a nasty habit of grabbing free looking IRQs and setting them to be
> edge triggered, which would obviously be bad. 

Can you provide more details for this problem and why we should
workaround it here instead of fixing the PCMCIA driver (hardware)?

A generic requirement for dynamic power management is the hardware
resource should not be touched when you put it in a low power state. In
this case, ipw2100 interrupt handler is possibly called (for example, it
shares the same IRQ with other devies) and it touches the card register,
which will cause problem. A possible workaround is to check the suspend
state in the beginning of the ISR and returns IRQ_NONE. But I think
freeing the irq handler before suspend should be the right way to go.

Thanks,
-yi

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
