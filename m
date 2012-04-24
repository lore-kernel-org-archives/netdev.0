From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v4] Add TCP encap_rcv hook (repost)
Date: Tue, 24 Apr 2012 09:13:17 -0700
Message-ID: <20120424091317.08953fd2@nehalam.linuxnetplumber.net>
References: <CAEP_g=_3om5aR=P0ffa9421KhvYYrMEeE33TNcCC9UV6+XVWAQ@mail.gmail.com>
	<20120423.161313.1582195533832554777.davem@davemloft.net>
	<CAEP_g=8EVOVgDaWnu3sd+qHxNZ7+ogjzBkuWvfVHNAqX2DRf=g@mail.gmail.com>
	<20120423.170817.1103719420692884446.davem@davemloft.net>
	<CAEP_g=-52GOr3LzbUB+97ftNQBZV=7NWXqfWN6GMfq5KmdO25A@mail.gmail.com>
	<20120423223255.GG580@verge.net.au>
	<CAEP_g=9p0TE59JbrS8QzHj4mEzc-5_hUDzmLRsRxLyUaFX+Z5Q@mail.gmail.com>
	<20120424022514.GB5357@verge.net.au>
	<807AC914-2F33-46C7-99DC-E2F8F0F97531@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "<dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"<eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>" <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"<jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>" <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, David-/PVsmBQoxgPKo9QCiBeYKEEOCMrvLtNR@public.gmane.org,
	"<stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>" <stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: "Kyle Mestery (kmestery)" <kmestery-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <807AC914-2F33-46C7-99DC-E2F8F0F97531-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Apr 2012 16:02:41 +0000
"Kyle Mestery (kmestery)" <kmestery-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org> wrote:

> On Apr 23, 2012, at 9:25 PM, Simon Horman wrote:
> > On Mon, Apr 23, 2012 at 03:59:24PM -0700, Jesse Gross wrote:
> >> On Mon, Apr 23, 2012 at 3:32 PM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> >>> On Mon, Apr 23, 2012 at 02:38:07PM -0700, Jesse Gross wrote:
> >>>> On Mon, Apr 23, 2012 at 2:08 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> >>>>> From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> >>>>> Date: Mon, 23 Apr 2012 13:53:42 -0700
> >>>>> 
> >>>>>> On Mon, Apr 23, 2012 at 1:13 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> >>>>>>> From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> >>>>>>> Date: Mon, 23 Apr 2012 13:08:49 -0700
> >>>>>>> 
> >>>>>>>> Assuming that the TCP stack generates large TSO frames on transmit
> >>>>>>>> (which could be the local stack; something sent by a VM; or packets
> >>>>>>>> received, coalesced by GRO and then encapsulated by STT) then you can
> >>>>>>>> just prepend the STT header (possibly slightly adjusting things like
> >>>>>>>> requested MSS, number of segments, etc. slightly).  After that it's
> >>>>>>>> possible to just output the resulting frame through the IP stack like
> >>>>>>>> all tunnels do today.
> >>>>>>> 
> >>>>>>> Which seems to potentially suggest a stronger intergration of the STT
> >>>>>>> tunnel transmit path into our IP stack rather than the approach Simon
> >>>>>>> is taking
> >>>>>> 
> >>>>>> Did you have something in mind?
> >>>>> 
> >>>>> A normal bonafide tunnel netdevice driver like GRE instead of the
> >>>>> openvswitch approach Simon is using.
> >>>> 
> >>>> Ahh, yes, that I agree with.  Independent of this, there's work being
> >>>> done to make it so that OVS can use the normal in-tree tunneling code
> >>>> and not need its own.  Once that's done I expect that STT will follow
> >>>> the same model.
> >>> 
> >>> Hi Jesse,
> >>> 
> >>> I am wondering how firm the plans to on allowing OVS to use in-tree tunnel
> >>> code are. I'm happy to move my efforts over to an in-tree STT implementation
> >>> but ultimately I would like to get STT running in conjunction with OVS.
> >> 
> >> I would say that it's a firm goal but the implementation probably
> >> still has a ways to go.  Kyle Mestery (CC'ed) has volunteered to work
> >> on this in support of adding VXLAN, which needs some additional
> >> flexibility that this approach would also provide.  You might want to
> >> talk to him to see if there are ways that you guys can work together
> >> on it if you are interested.  Having better integration with upstream
> >> tunneling is definitely a step that OVS needs to make and sooner would
> >> be better than later.
> > 
> > Hi Jesse, Hi Kyle,
> > 
> > that sounds like an excellent plan.
> > 
> > Kyle, do you have any thoughts on how we might best work together on this?
> > Perhaps there are some patches floating around that I could take a look at?
> > 
> 
> Hi Simon:
> 
> The VXLAN work has been slow going for me at this point. What I have works, but is far from complete. It's available here:
> 
> https://github.com/mestery/ovs-vxlan/tree/vxlan
> 
> This is based on a fairly recent version of OVS. I'm currently working to allow tunnels to be flow-based rather than port-based, as they currently exist. As Jesse may have mentioned, doing this allows us to move most tunnel state into user space. The outer header can now be part of the flow lookup and can be passed to user space, so things like multicast learning for VXLAN become possible.
> 
> With regards to working together, ping me off-list and we can work something out, I'm very much in favor of this!
> 

My use of VXVLAN was to be key based (like existing GRE), not flow based.
