From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [e1000]: flow control on by default - good idea really?
Date: Tue, 17 Oct 2006 11:25:34 -0700
Message-ID: <20061017112534.1071362f@freekitty>
References: <44AC05A8.9030503@intel.com>
	<Pine.LNX.4.64.0607052241230.12611@bizon.gios.gov.pl>
	<1152191018.5103.48.camel@jzny2>
	<20060706.235909.78729229.davem@davemloft.net>
	<1152275283.5341.144.camel@jzny2>
	<4533D594.2070908@intel.com>
	<1161090331.5555.10.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, Robert.Olsson@data.slu.se,
	john.ronciak@intel.com, greearb@candelatech.com, jgarzik@pobox.com,
	olel@ans.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:19672 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751420AbWJQSg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 14:36:58 -0400
To: hadi@cyberus.ca
In-Reply-To: <1161090331.5555.10.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 17 Oct 2006 09:05:31 -0400
jamal <hadi@cyberus.ca> wrote:

> On Mon, 2006-16-10 at 11:55 -0700, Auke Kok wrote:
> > jamal wrote:
> 
> > > I think when the e1000 says via ethtool "rx is on" - it means that it 
> > > is _advertising_ flow control as opposed to detecting partner has flow
> > > control capability.
> > > Auke, can you also check this as well?
> > 
> > Just found this in my todo box - a bit late :(
> > 
> > yes, that appears to be the correct interpretation: we never read back the 
> > detected FC  state from the hardware.
> > 
> 
> It sounds to me that ethttool needs to have this semantic fix.
> IOW, ethttool doesnt differentiate the two items:
> a) advertised parameters.
> b) link partner negotiated parameters.
> 
> and instead #a becomes #b after negotiation.
> 
> methinks this needs fixing. Dave? Jeff?
> 
> cheers,
> jamal

If #a becomes #b after negotiation, that is a bug.
Otherwise, if imagine that connection was moved from gigabit with flow control
to 10mbit with no flow control, then back to gigabit with flow control.
You would want the advertised parameters to stay the same and not change.

I think driver need to keep track of advertising and status bits
in separate fields.

Another pet bug, is that drivers need to accept and remember ethtool
settings when offline before device is brought up. The existing if_mii 
interface doesn't do that, and so drivers that use it are broken.

-- 
Stephen Hemminger <shemminger@osdl.org>
