From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: Re: e1000 and 802.1ad/stacked vlan tagging
Date: Mon, 28 Aug 2006 19:38:32 +0200
Message-ID: <20060828193832.359651a1.skraw@ithnet.com>
References: <36D9DB17C6DE9E40B059440DB8D95F5286678F@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sf.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5286678F@orsmsx418.amr.corp.intel.com>
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

Hello Jesse,

thank you for answering anyway. Though I think your answer covers only the
obvious half of the problem.
Indeed one might think that this solves the issue - as long as there are only
linux kernels involved. Unfortunately my setup is a bit more complicated in
terms of hardware. So I should have probably clarified the question this way:
how do you configure the interface in a manner that packets with data length
of 1500 get transferred, and not only 1496 ?
I tried enlarging both real-device and first vlan interface mtu but that does
not work out. I really thought that the visible device setting of mtu=1500
should have worked out and that the driver (or some code in between) should
have corrected the allowed frame size to reflect the actual setup, not?

Regards,
Stephan

PS: crossposted to both lists, list-members keep in mind I am not subscribed
when answering! Thank you.



On Mon, 28 Aug 2006 10:23:09 -0700
"Brandeburg, Jesse" <jesse.brandeburg@intel.com> wrote:

> Stephan von Krawczynski wrote:
> > Hello Jesse,
> > 
> > sorry to bother you directly, but since you did the patch for my e1000
> > interrupt problem last time (February) I hope you have a short-hand
> > idea for my current issue, too.
> > 
> > I am trying to make stacked vlan tagging work under kernel 2.4 with
> > e1000. Generally I do this on two boxes connected back-to-back:
> > 
> > ifconfig eth0 up
> > vconfig add eth0 4094
> > ifconfig eth0.4094 up
> > vconfig add eth0.4094 1
> > ifconfig eth0.4094.1 192.168.1.1 netmask 255.255.255.0 broadcast
> > 192.168.1.255 up
> > 
> > (of course the second box gets another ip, lets assume .2).
> > 
> > if you do a
> > 
> > ping -s 1472 192.168.1.2
> > 
> > through the stacked vlan you see the packets vanish.
> > With
> > 
> > ping -s 1468 192.168.1.2
> > 
> > everything seems ok.
> > 
> > I have the impression that the stacked vlans show some problem with
> > mtu handling inside the e1000 driver. Mtu is set to 1500 but because
> > stacking tags uses 4 bytes more the packets cannot use the full mtu.
> > Any ideas what happens here?
> 
> The packet is being dropped because it is longer than the allowed frame
> size for 1500 MTU.  check ethtool -S eth0
> 
> mine shows 
> rx_long_length_errors: 169
> 
> which indicates that you need to change your mtu on the stacked
> interface to 1496, at which point after I did:
> 
> ip l s eth1.4094.1 mtu 1496
> 
> on both sides of my connection, everything was working.  I think in this
> case it is just a configuration problem.  When you stack vlans you have
> to account for the extra inserted length someplace and that place is by
> reducing the MTU.
> 
> I'd appreciate it in the future if you could use
> e1000-devel@lists.sf.net or netdev@vger.kernel.org for support questions
> like this because I'm not the only one who can answer questions (and I
> might have been on vacation! :-) )
> 
> Jesse
> 


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
