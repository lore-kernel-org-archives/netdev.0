From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>
Subject: Re: [PATCH net-next] net: remove abuse of VLAN DEI/CFI bit
Date: Wed, 14 Dec 2016 15:28:30 +0100
Message-ID: <20161214142830.54gdkfkpzlcdx4my@rere.qmqm.pl>
References: <cfa1f2efae2217b50cbefccbf9ba7f0d24a23c63.1480755768.git.mirq-linux@rere.qmqm.pl>
	<20161213172118.2f55c503@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-2"
Content-Transfer-Encoding: quoted-printable
Cc: "open list:OPENVSWITCH" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"moderated list:ETHERNET BRIDGE" <bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161213172118.2f55c503@xeon-e3>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 13, 2016 at 05:21:18PM -0800, Stephen Hemminger wrote:
> On Sat,  3 Dec 2016 10:22:28 +0100 (CET)
> Micha=B3 Miros=B3aw <mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org> wrote:
> =

> > This All-in-one patch removes abuse of VLAN CFI bit, so it can be passed
> > intact through linux networking stack.
> > =

> > Signed-off-by: Micha=B3 Miros=B3aw <michal.miroslaw-sjE0K2xrq/hHxbwTTUZ4aWZHpeb/A1Y/@public.gmane.org>
> > ---
> > =

> > Dear NetDevs
> > =

> > I guess this needs to be split to the prep..convert[]..finish sequence,
> > but if you like it as is, then it's ready.
> > =

> > The biggest question is if the modified interface and vlan_present
> > is the way to go. This can be changed to use vlan_proto !=3D 0 instead
> > of an extra flag bit.
> > =

> > As I can't test most of the driver changes, please look at them careful=
ly.
> > OVS and bridge eyes are especially welcome.
> > =

> > Best Regards,
> > Micha=B3=A0Miros=B3aw
> =

> Is the motivation to support 802.1ad Drop Eligability Indicator (DEI)?
> =

> If so then you need to be more verbose in the commit log, and lots more
> work is needed. You need to rename fields and validate every place a
> driver is using DEI bit to make sure it really does the right thing
> on that hardware. It is not just a mechanical change.

There are not many mentions of CFI bit in the Linux tree. Places that
used it as VLAN_TAG_PRESENT are fixed with this patchset. Other uses are:

 - VLAN code: ignored
 - ebt_vlan: ignored
 - OVS: cleared because of netlink API assumptions
 - DSA: transferred to/from (E)DSA tag
 - drivers: gianfar: uses properly in filtering rules
 - drivers: cnic: false-positive (uses only VLAN ID, CFI bit marks the fiel=
d 'valid')
 - drivers: qedr: false-positive (like cnic)

So unless there is something hidden in the hardware, no driver does anything
special with the CFI bit.

After this patchset only OVS will need further modifications to be able to
support handling of DEI bit.

Best Regards,
Micha=B3=A0Miros=B3aw
