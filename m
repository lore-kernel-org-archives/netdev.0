From: Dave Boutcher <daveboutcher@gmail.com>
Subject: Re: IGMP Join dropping multicast packets
Date: Wed, 18 Mar 2009 20:51:03 -0500
Message-ID: <91bdcedb0903181851v2b3190bekb832df227910e844@mail.gmail.com>
References: <91bdcedb0903141316j2dbf4160wb348a5a9e3bde8ad@mail.gmail.com>
	<49BC69D5.5000002@cosmosbay.com>
	<91bdcedb0903151904x1066ac24h63557b588e7c4967@mail.gmail.com>
	<49BEA1ED.4010907@cosmosbay.com>
	<91bdcedb0903172050td2ef895he48168987ad94472@mail.gmail.com>
	<alpine.WNT.2.00.0903181016120.5116@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: e1000-devel@lists.sourceforge.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <dada1@cosmosbay.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.WNT.2.00.0903181016120.5116@jbrandeb-desk1.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Mar 18, 2009 at 12:24 PM, Brandeburg, Jesse
<jesse.brandeburg@intel.com> wrote:
>
> On Tue, 17 Mar 2009, Dave Boutcher wrote:
> > Eric, based on your inability to recreate this, I tried on some other
> > hardware I had lying around that has an AMD chipset built-in NIC.
> > I could not recreate the problem on that hardware. =A0I'm starting to
> > think this is an e1000 problem. =A0In both the e1000 and e1000e
> > drivers they do the following logic:
> >
> > =A0 =A0 =A0 /* clear the old settings from the multicast hash table */
> >
> > =A0 =A0 =A0 =A0for (i =3D 0; i < mta_reg_count; i++) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0E1000_WRITE_REG_ARRAY(hw, MTA, i, 0);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0E1000_WRITE_FLUSH();
> > =A0 =A0 =A0 =A0}
> >
> > =A0 =A0 =A0 =A0/* load any remaining addresses into the hash table */
> >
> > =A0 =A0 =A0 =A0for (; mc_ptr; mc_ptr =3D mc_ptr->next) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hash_value =3D e1000_hash_mc_addr(hw, mc=
_ptr->da_addr);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0e1000_mta_set(hw, hash_value);
> > =A0 =A0 =A0 =A0}
> >
> > There's clearly a window where the NIC doesn't have the multicast
> > addresses loaded. =A0This may just be broken-as-designed. =A0If anyone
> > else happens to have some e1000 hardware and wants to see if you
> > can recreate this, I'd be curious.
> >
> > Some other notes just FYI...
> >
> > - RcvbufErrors in /proc/net/snmp doesn't get incremented when this happ=
ens
> > - there are no messages in dmesg
> > - frames get dropped when the program calls exit() and all the sockets
> > get closed
> > =A0 (and multicast joins dropped) as well as when the ADD_MEMBERSHIPs h=
appen
> > - The problem happens even when adding a sleep(1) in between each of the
> > =A0 ADD_MEMBERSHIP calls.
>
> Interesting, this code has been there for eons (and probably this
> behavior) but that doesn't mean its not a problem.

Hi Jesse, thanks for the response...

If you go back in this thread I had a dead easy unprivileged user-land test=
case
that causes frame loss. =A0We ran into this in a production environment
(and I kind
of glossed over how long it took to figure out why the hell we were dropping
frames...you can only increase rmem_max so many times ;-) =A0OTOH not that =
many
people use multicast, and even fewer notice a few dropped frames, so the
priority is probably lowish.

On the other other hand, I'm working in the financial trading space these d=
ays,
where Linux is pretty much king....and they're all about multicast.

--
Dave B

---------------------------------------------------------------------------=
---
Apps built with the Adobe(R) Flex(R) framework and Flex Builder(TM) are
powering Web 2.0 with engaging, cross-platform capabilities. Quickly and
easily build your RIAs with Flex Builder, the Eclipse(TM)based development
software that enables intelligent coding and step-through debugging.
Download the free 60 day trial. http://p.sf.net/sfu/www-adobe-com
