From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: bonding (IEEE 802.3ad) not working with qemu/virtio
Date: Sun, 31 Jan 2016 16:58:42 +0200
Message-ID: <20160131165501-mutt-send-email-mst@redhat.com>
References: <CAJO99TmB3957Wq3Cse7azgBxKeZ2BV6QihoyAsjUjyvzc-V8dQ@mail.gmail.com>
	<56ABDA3D.8040100@cumulusnetworks.com> <28285.1454103900@famine>
	<56ABDE2A.7010301@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Jiri Pirko <jiri@resnulli.us>, Andy Gospodarek <gospo@cumulusnetworks.com>,
	virtualization@lists.linux-foundation.org,
	=?iso-8859-1?Q?Bj=F8rnar?= Ness <bjornar.ness@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>, netdev <netdev@vger.kernel.org>,
	Jay Vosburgh <jay.vosburgh@canonical.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <56ABDE2A.7010301@cumulusnetworks.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 29, 2016 at 10:48:26PM +0100, Nikolay Aleksandrov wrote:
> On 01/29/2016 10:45 PM, Jay Vosburgh wrote:
> > Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
> > =

> >> On 01/25/2016 05:24 PM, Bj=F8rnar Ness wrote:
> >>> As subject says, 802.3ad bonding is not working with virtio network m=
odel.
> >>>
> >>> The only errors I see is:
> >>>
> >>> No 802.3ad response from the link partner for any adapters in the bon=
d.
> >>>
> >>> Dumping the network traffic shows that no LACP packets are sent from =
the
> >>> host running with virtio driver, changing to for example e1000 solves
> >>> this problem
> >>> with no configuration changes.
> >>>
> >>> Is this a known problem?
> >>>
> >> [Including bonding maintainers for comments]
> >>
> >> Hi,
> >> Here's a workaround patch for virtio_net devices that "cheats" the
> >> duplex test (which is the actual problem). I've tested this locally
> >> and it works for me.
> >> I'd let the others comment on the implementation, there're other signs
> >> that can be used to distinguish a virtio_net device so I'm open to sug=
gestions.
> >> Also feedback if this is at all acceptable would be appreciated.
> > =

> > 	Should virtio instead provide an arbitrary speed and full duplex
> > to ethtool, as veth does?
> > =

> > 	Creating a magic whitelist of devices deep inside the 802.3ad
> > implementation seems less desirable.
> > =

> TBH, I absolutely agree. In fact here's what we've been doing:
> add set_settings which allows the user to set any speed/duplex
> and get_settings of course to retrieve that. This is also useful
> for testing other stuff that requires speed and duplex, not only
> for the bonding case.

This looks like a very reasonable thing to do:
user might have knowledge of the actual speed through
some side-channel.

We might also propagate it to hypervisor in the future.

And this sound useful even if bonding is changed
to allow DUPLEX_UNKNOWN.

So please post this patch.


> I'll add the virtio_net maintainers to the discussion, see if it's
> okay with everyone and I'll move to send patches once net-next opens up.
> =

> Thanks!
> =

> =

> > 	-J
> > 	=

> > ---
> > 	-Jay Vosburgh, jay.vosburgh@canonical.com
> > =
