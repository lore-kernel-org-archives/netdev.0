From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: NAPI, e100, and system performance problem
Date: Sat, 23 Apr 2005 19:54:13 +0200
Message-ID: <17002.35781.813292.517029@robur.slu.se>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
	<Pine.LNX.4.61.0504180943290.15052@linux.site>
	<1113855967.7436.39.camel@localhost.localdomain>
	<20050419055535.GA12211@sgi.com>
	<m1hdhzyrdz.fsf@muc.de>
	<1114173195.7679.30.camel@localhost.localdomain>
	<20050422172108.GA10598@muc.de>
	<1114193902.7978.39.camel@localhost.localdomain>
	<20050422232831.GB6462@sgi.com>
	<20050423094038.72a8da73@localhost.localdomain>
	<20050422164301.724343f6.davem@davemloft.net>
	<20050423125153.65189ea0@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, gnb@sgi.com, hadi@cyberus.ca,
        ak@muc.de, akepner@sgi.com, jesse.brandeburg@intel.com,
        netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050423125153.65189ea0@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Stephen Hemminger writes:

 > One of the problem with the dynamic schemes, is there is no generic infrastructure
 > to support it. There are some drivers that have tried dynamic schemes
 > but each seems to reinvent some adhoc scheme. Seems like a good area
 > for future research.

 Well how do decorrelate bursty network and more interesing at what 
 time level? I said this before... the only useful measure for mitigation
 setting was packets on RX ring.
 
 > Another related problem is some drivers use NAPI for both TX and RX and
 > this can cause asymmetric behavior and scheduling issues. The whole
 > dev->weight limit stuff assumes RX not TX usage of NAPI

 Well in the very beginning it was thought only RX yes, But it is possible 
 also to have TX buffer cleared etc in the ->poll routine to simplify 
 intr. acking. As implemented only RX packets updates the budget.
 From what I see in real life use this works well. Guess you noticed the 
 tests with e1000 and TCP just posted. 

 Anyway MSI will give us some new options in this area..

 Cheers.
					--ro
