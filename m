From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: skbuff truesize incorrect.
Date: Fri, 23 May 2014 07:00:22 -0700
Message-ID: <1400853622.5367.196.camel@edumazet-glaptop2.roam.corp.google.com>
References: <537E4AFD.20304@mentor.com>
	 <1400792295.5367.174.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1400792601.5367.176.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140522.171033.1040508444998374401.davem@davemloft.net>
	 <87ppj5vupf.fsf@nemi.mork.no> <537F0DCA.6030901@mentor.com>
	 <87vbsw4z5x.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jim Baxter <jim_baxter@mentor.com>,
	David Miller <davem@davemloft.net>, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kamal@canonical.com, edumazet@google.com, mszeredi@suse.cz,
	fw@strlen.de
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87vbsw4z5x.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-05-23 at 11:33 +0200, Bj=C3=B8rn Mork wrote:
> Jim Baxter <jim_baxter@mentor.com> writes:
>=20
> >> I'll create and test a patch for the cdc_ncm host driver unless so=
meone
> >> else wants to do that. I haven't really played with the gadget dri=
ver
> >> before, so I'd prefer if someone knowing it (Jim maybe?) could tak=
e care
> >> of it.  If not, then I can always make an attempt using dummy_hcd =
to
> >> test it.
> > I can create a patch for the host driver, I will issue the gadget p=
atch
> > first to resolve any issues, the fix would be similar.
>=20
> Well, I couldn't help myself.  I just had to test it.  The attached
> patch works for me, briefly tested with an Ericsson H5321gw NCM devic=
e.
> I have no ideas about the performance impact as that modem is limited=
 to
> 21 Mbps HSDPA.

Ideally, the skb_in should not be freed/reallocated, but recycled,
especially if using 32KB.

But thats a minor detail, this patch is already a huge win for a 21Mbps
device.

Acked-by: Eric Dumazet <edumazet@google.com>
