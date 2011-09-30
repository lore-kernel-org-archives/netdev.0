From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: tg3: BMC stops responding in 3.0
Date: Fri, 30 Sep 2011 16:53:53 -0700
Message-ID: <20110930235353.GB16743@mcarlson.broadcom.com>
References: <201109232145.50449.a.miskiewicz@gmail.com>
 <201109262031.33956.a.miskiewicz@gmail.com>
 <20110929235701.GA9513@mcarlson.broadcom.com>
 <201109301006.25590.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Arkadiusz Mi??kiewicz" <a.miskiewicz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4543 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755009Ab1I3Xyr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Sep 2011 19:54:47 -0400
In-Reply-To: <201109301006.25590.a.miskiewicz@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 30, 2011 at 01:06:25AM -0700, Arkadiusz Mi??kiewicz wrote:
> On Friday 30 of September 2011, Matt Carlson wrote:
> > On Mon, Sep 26, 2011 at 11:31:33AM -0700, Arkadiusz Mi??kiewicz wrote:
> > > On Monday 26 of September 2011, Matt Carlson wrote:
> > > > On Fri, Sep 23, 2011 at 12:45:50PM -0700, Arkadiusz Mi??kiewicz wrote:
> > > > > Hi,
> > > > > 
> > > > > I was using 2.6.38.8 and recently tried to switch to 3.0.4 on Tyan
> > > > > S2891 platform.
> > > > > 
> > > > > This platform uses tg3:
> > > > > tg3 0000:0a:09.1: eth1: Tigon3 [partno(BCM95704) rev 2003]
> > > > > (PCIX:133MHz:64- bit) MAC address 00:e0:81:33:5e:af
> > > > > tg3 0000:0a:09.1: eth1: attached PHY is 5704 (10/100/1000Base-T
> > > > > Ethernet) (WireSpeed[1], EEE[0])
> > > > > tg3 0000:0a:09.1: eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0]
> > > > > TSOcap[1] tg3 0000:0a:09.1: eth1: dma_rwctrl[769f4000]
> > > > > dma_mask[64-bit]
> > > > > 
> > > > > With 2.6.38.8 everything was working fine. With 3.0.4 there is a
> > > > > problem. As soon as tg3 module is loaded or eth0 configured (can't
> > > > > tell which one since the machine is 400km away from me and I have no
> > > > > way to play with it other than ipmi or ssh) BMC stops responding (so
> > > > > all ipmitool commands over LAN stop working). Normal tg3 activity is
> > > > > not affected - I can ssh-in without a problem etc but ipmi over lan
> > > > > doesn't work.
> > > > > 
> > > > > From ssh console "ipmitool lan print" works, shows data but for
> > > > > example after "ipmitool mc reset cold" it doesn't recover - ipmitool
> > > > > returns "Invalid channel: 255". I have to reboot to 2.6.38.8 and
> > > > > then issue "ipmitool mc reset cold" to recover.
> > > > > 
> > > > > Any idea which tg3 change could break this? Can't bisect this due
> > > > > remote access only.
> > > > > 
> > > > > I was hoping that maybe 9e975cc291d80d5e4562d6bed15ec171e896d69b
> > > > > "tg3: Fix io failures after chip reset" will fix things for me but no
> > > > > - this doesn't help.
> > > > 
> > > > What version of the tg3 driver are you working with?
> > > 
> > > The one in 3.0.4 kernel. I think it's 3.119 (at least modinfo says so).
> > 
> > Unfortunately there were a lot of changes between 3.117 and 3.119(+).
> > Is there any way you can narrow down the gap?
> 
> The machines are 400km away from me and it's hard to debug that way then 
> ipmi/network conectivity is in stake :-/ I could try some form of bisecting 
> but need to know if all git versions between 3.117 and 3.119 were known to be 
> safe and working? I don't want to loose any conectivity to this machine.
> 
> I was going to try 2.6.39 but it looks like it also uses 3.117 driver.

O.K.  Can you give me the details of your machine?  Maybe we have the
exact machine or a machine similar enough to reproduce the problem with.
