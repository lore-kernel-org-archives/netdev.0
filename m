From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH V2 3/3] Ixgbevf: Add migration support for ixgbevf
 driver
Date: Wed, 25 Nov 2015 14:28:05 +0200
Message-ID: <20151125142437-mutt-send-email-mst@redhat.com>
References: <1448372298-28386-1-git-send-email-tianyu.lan@intel.com>
 <1448372298-28386-4-git-send-email-tianyu.lan@intel.com>
 <20151124230551-mutt-send-email-mst@redhat.com>
 <56554994.1090305@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: a.motakis-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org, alex.williamson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	b.reynal-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org, bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	carolyn.wyborny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	eddie.dong-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, nrupal.jani-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, agraf-l3A5Bk7waGM@public.gmane.org,
	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, qemu-devel-qX2TKyscuCcdnm+yROfE0A@public.gmane.org,
	emil.s.tantilov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	mark.d.rustad-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, eric.auger-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	jesse.brandeburg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, john.ronciak-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	matthew.vick-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, mitch.a.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shannon.nelson-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	weiyang-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Lan Tianyu <tianyu.lan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <56554994.1090305-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 25, 2015 at 01:39:32PM +0800, Lan Tianyu wrote:
> On 2015=E5=B9=B411=E6=9C=8825=E6=97=A5 05:20, Michael S. Tsirkin wrot=
e:
> > I have to say, I was much more interested in the idea
> > of tracking dirty memory. I have some thoughts about
> > that one - did you give up on it then?
>=20
> No, our finial target is to keep VF active before doing
> migration and tracking dirty memory is essential. But this
> seems not easy to do that in short term for upstream. As
> starters, stop VF before migration.

=46rankly, I don't really see what this short term hack buys us,
and if it goes in, we'll have to maintain it forever.

Also, assuming you just want to do ifdown/ifup for some reason, it's
easy enough to do using a guest agent, in a completely generic way.


> After deep thinking, the way of stopping VF still needs tracking
> DMA-accessed dirty memory to make sure the received data buffer
> before stopping VF migrated. It's easier to do that via dummy writing
> data buffer when receive packet.
>=20
>=20
> --=20
> Best regards
> Tianyu Lan
