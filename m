From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: e1000 and 802.1ad/stacked vlan tagging
Date: Mon, 28 Aug 2006 13:53:36 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52866B22@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sf.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-class: urn:content-classes:message
To: "Stephan von Krawczynski" <skraw@ithnet.com>
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

Stephan von Krawczynski wrote:
> thank you for answering anyway. Though I think your answer covers
> only the obvious half of the problem.
> Indeed one might think that this solves the issue - as long as there
> are only linux kernels involved. Unfortunately my setup is a bit more
> complicated in terms of hardware. So I should have probably clarified
> the question this way: how do you configure the interface in a manner
> that packets with data length of 1500 get transferred, and not only
> 1496 ? 

I tried setting mtu 2000 and everything worked with the virtual device
(both) mtu at 1500.
If you are getting long_packet errors at the mtu settings you tried (you
didn't mention which ones) then the hardware is dropping the packets due
to being over 1522 bytes in length (including CRC).

> I tried enlarging both real-device and first vlan interface mtu but
> that does not work out. I really thought that the visible device
> setting of mtu=1500 should have worked out and that the driver (or
> some code in between) should have corrected the allowed frame size to
> reflect the actual setup, not? 

unfortunately I believe that your hardware MTU on the base interface
MUST be adjusted in order to do stacked vlans because the vlan code
doesn't fragment packets, it just inserts tags.  The e1000 hardware is
capable of inserting/stripping 1 level of tags without dropping overlong
frames, but cannot seamlessly handle 1+n levels of inserted tags.
Transmit, we don't care how long the frames are that are given to us
(the driver doesn't enforce MTU on transmit) but on receive we have
limited space so it is important that each frame fit into the allocated
buffer (including CRC).

Please try MTU 1508 on eth0 (base interface only), as that configuration
worked for me.

Jesse

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
