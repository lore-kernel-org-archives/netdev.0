From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6] update to network emulation QOS scheduler
Date: Wed, 7 Jul 2004 13:58:31 -0700
Sender: lartc-admin@mailman.ds9a.nl
Message-ID: <20040707135831.4c98dd51@dell_ss3.pdx.osdl.net>
References: <20040701113312.43cfe6c5@dell_ss3.pdx.osdl.net>
	<20040702134437.5891e998@dell_ss3.pdx.osdl.net>
	<1088824432.1043.271.camel@jzny.localdomain>
	<20040707111055.32ebb25b@dell_ss3.pdx.osdl.net>
	<1089226667.1027.411.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>,
	Catalin BOIE <util@deuroconsult.ro>, netdev@oss.sgi.com,
	lartc@mailman.ds9a.nl
Return-path: <lartc-admin@mailman.ds9a.nl>
To: hadi@cyberus.ca
In-Reply-To: <1089226667.1027.411.camel@jzny.localdomain>
Errors-To: lartc-admin@mailman.ds9a.nl
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Subscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
List-Unsubscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc/>
List-Id: netdev.vger.kernel.org

On 07 Jul 2004 14:57:48 -0400
jamal <hadi@cyberus.ca> wrote:

> I seem to have hit the jackpot - all my emails to netdev are showing
> up and on time too.
> 
> On Wed, 2004-07-07 at 14:10, Stephen Hemminger wrote:
> > Ok, I'll bite how would you do:
> > 
> > Rate limit packet egress on a ethernet device (eth0) so it looks like a slow DSL link (25 Kbps)
> > by not dropping packets but by pacing the data.
> 
> Doesnt TBF work? 
> rate 25kbit burst 90k should probably do it.  Maybe i misunderstood the
> question.

TBF works but since the sender (on the same local machine) may go over it's allocation,
it will drop packets.

For example, if I use tbf to simulate a slow 33k bits/sec link then TCP test never
completes, it just hangs!  TBF does work for intermediate sizes.

But if I use the pacing simulation it works.

> 
> You may be able to avoid dropping but dont think you can guarantee it
> simply because you have finite buffers. At some point you will congest
> that queue and packets will be dropped; and if you dont limit your queue
> buffer size, sooner than later you are bound to hog all the system
> memory.

I understand that, every queue has to have a limit.

> Having said that, i have never seen a good arguement for why pacing
> traffic vs dropping to initiate a slowdown is better than the other.
> So in that case, a policer/meter should suffice.


_______________________________________________
LARTC mailing list / LARTC@mailman.ds9a.nl
http://mailman.ds9a.nl/mailman/listinfo/lartc HOWTO: http://lartc.org/
