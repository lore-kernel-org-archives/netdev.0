From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Xen-devel] [RFC v2 1/4] bridge: enable interfaces to
 opt out from becoming the root bridge
Date: Thu, 20 Feb 2014 09:19:58 -0800
Message-ID: <20140220091958.62a8b444@nehalam.linuxnetplumber.net>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
	<1392433180-16052-2-git-send-email-mcgrof@do-not-panic.com>
	<20140216105754.63738163@nehalam.linuxnetplumber.net>
	<CAB=NE6WwbOXNLO_Mn42i7y62pEsmDOWd35B621eiJk4iaE3Hfg@mail.gmail.com>
	<1392803559.23084.99.camel@kazak.uk.xensource.com>
	<5304C13F.3030802@citrix.com>
	<CAB=NE6X6Vuo3iib0W-c5cxv0QBpnZtCC0sFyuULugQoEZAbRtg@mail.gmail.com>
	<20140219090855.610c0e04@nehalam.linuxnetplumber.net>
	<CAB=NE6UAqoiFAJdckE1d7cgMZnU6_=8X+N=tSc6qH2bgH08M7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>, kvm@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Zoltan Kiss <zoltan.kiss@citrix.com>, xen-devel@lists.xenproject.org
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CAB=NE6UAqoiFAJdckE1d7cgMZnU6_=8X+N=tSc6qH2bgH08M7Q@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Feb 2014 09:59:33 -0800
"Luis R. Rodriguez" <mcgrof@do-not-panic.com> wrote:

> On Wed, Feb 19, 2014 at 9:08 AM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> > On Wed, 19 Feb 2014 09:02:06 -0800
> > "Luis R. Rodriguez" <mcgrof@do-not-panic.com> wrote:
> >
> >> Folks, what if I repurpose my patch to use the IFF_BRIDGE_NON_ROOT (or
> >> relabel to IFF_ROOT_BLOCK_DEF) flag for a default driver preference
> >> upon initialization so that root block will be used once the device
> >> gets added to a bridge. The purpose would be to avoid drivers from
> >> using the high MAC address hack, streamline to use a random MAC
> >> address thereby avoiding the possible duplicate address situation for
> >> IPv6. In the STP use case for these interfaces we'd just require
> >> userspace to unset the root block. I'd consider the STP use case the
> >> most odd of all. The caveat to this approach is 3.8 would be needed
> >> (or its the root block patches cherry picked) for base kernels older
> >> than 3.8.
> >>
> >> Stephen?
> >>
> >>   Luis
> >
> > Don't add IFF_ flags that adds yet another API hook into bridge.
> 
> The goal was not to add a userspace API, but rather consider a driver
> initialization preference.
> 
> > Please only use the netlink/sysfs flags fields that already exist
> > for new features.
> 
> Sure, but what if we know a driver in most cases wants the root block
> and we'd want to make it the default, thereby only requiring userspace
> for toggling it off.
> 
>   Luis

Something in userspace has to put the device into the bridge.
Fix the port setup in that tool via the netlink or sysfs flags in
the bridge. It should not have to be handled in the bridge looking
at magic flags in the device.
