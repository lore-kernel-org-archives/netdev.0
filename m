From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH stable-only] virtio-net: fix build on m68k and sparc64
Date: Wed, 15 Jan 2014 11:15:18 +0200
Message-ID: <20140115091518.GE1719@redhat.com>
References: <1389774152-1526-1-git-send-email-mst@redhat.com>
	<CAMuHMdV=qzDApabSiQj9up_RUW=PoVJA8oWaiWY7d2iQ22AfeQ@mail.gmail.com>
	<20140115084605.GF29177@redhat.com>
	<CAMuHMdW4io2BcPvR-VwLMrCNReTEcUeNgO1ievVw+Eg=UdyeuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	virtualization@lists.linux-foundation.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>, Guenter Roeck <linux@roeck-us.net>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <CAMuHMdW4io2BcPvR-VwLMrCNReTEcUeNgO1ievVw+Eg=UdyeuA@mail.gmail.com>
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

On Wed, Jan 15, 2014 at 10:01:49AM +0100, Geert Uytterhoeven wrote:
> On Wed, Jan 15, 2014 at 9:46 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > On Wed, Jan 15, 2014 at 09:36:13AM +0100, Geert Uytterhoeven wrote:
> >> On Wed, Jan 15, 2014 at 9:26 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> >> > As a result of backporting a bugfix, virtio_net started passing void *
> >> > to page_address, assuming that it will get silently converted to struct
> >> > page *. But this does not happen on architectures where page_address is
> >> > a macro, the result is build failure as the macro tries to dereference
> >> > void*.
> >> >
> >> > Fix by reordering code slightly, so we always pass
> >> > struct page * to page_address.
> >>
> >> Thanks for the clue! I was just investigating a similar failure in -next.
> >>
> >> Gr{oetje,eeting}s,
> >>
> >>                         Geert
> >
> > You don't mean linux-next? And not in virtio-net? I don't see page_address
> > being used on void * anywhere there.
> 
> http://kisskb.ellerman.id.au/kisskb/buildresult/10469287/

Wew, so it's not my fault :)

> I'm making {,set}page_address() static inline to fix this.

Yes, I don't see why it has to be a macro.

> Gr{oetje,eeting}s,
> 
>                         Geert
> 
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
> 
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                 -- Linus Torvalds
