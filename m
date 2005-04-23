From: jamal <hadi@cyberus.ca>
Subject: Re: NAPI, e100, and system performance problem
Date: Fri, 22 Apr 2005 23:04:25 -0400
Message-ID: <1114225465.7669.27.camel@localhost.localdomain>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
	 <Pine.LNX.4.61.0504180943290.15052@linux.site>
	 <1113855967.7436.39.camel@localhost.localdomain>
	 <20050419055535.GA12211@sgi.com> <m1hdhzyrdz.fsf@muc.de>
	 <1114173195.7679.30.camel@localhost.localdomain>
	 <20050422172108.GA10598@muc.de>
	 <1114193902.7978.39.camel@localhost.localdomain>
	 <20050422232831.GB6462@sgi.com>
	 <20050423094038.72a8da73@localhost.localdomain>
	 <20050422164301.724343f6.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, gnb@sgi.com, ak@muc.de,
        akepner@sgi.com, jesse.brandeburg@intel.com, netdev@oss.sgi.com,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050422164301.724343f6.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-22-04 at 16:43 -0700, David S. Miller wrote:

> With the dynamic schemes comes a new issue, how quickly to respond
> to changes in traffic patterns.

Unfortunately, dynamic adjustment of mitigation parameters - in my
experiments at least (pre-NAPI) - show stability is hard to achieve.
In fact the early tulip driver had about 8 levels of mitigation (that i
put in and later taken out by Robert due to the instability).

The one thing that has been tossed around is to modify the state machine
such that the netdev is not taken out of the poll list for at least one
more poll round or a timeout period. I did try this a while back and the
extra poll did consume extra CPU - it probably isnt as bad as done by
extra PIO(s); 

I still think static mitigation + NAPI should do it.

cheers,
jamal
