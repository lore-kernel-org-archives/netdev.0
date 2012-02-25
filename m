From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 03/11] cirrus/mac89x0: print MAC via printk format specifier
Date: Sat, 25 Feb 2012 11:15:21 +0100
Message-ID: <CAMuHMdXAwgtwbCV_=qJnrs=YPZksoEBkjnQB=JbR7fc+UyKdzw@mail.gmail.com>
References: <1330091162-8141-1-git-send-email-danny.kukawka@bisect.de>
	<1330091162-8141-4-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Danny Kukawka <dkukawka@suse.de>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330091162-8141-4-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 24, 2012 at 14:45, Danny Kukawka <danny.kukawka@bisect.de> =
wrote:
> Print MAC/dev_addr via printk extended format specifier %pM instead
> of custom code.
>
> Use memcpy to set the address to dev->dev_addr in set_mac_address,
> instead of mxing it up in a for loop with printing a debug msg.
>
> Check also if the given address is valid.

Why do you sneak in this check in this patch?

> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
> ---
> =C2=A0drivers/net/ethernet/cirrus/mac89x0.c | =C2=A0 12 ++++++++----
> =C2=A01 files changed, 8 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/cirrus/mac89x0.c b/drivers/net/ethe=
rnet/cirrus/mac89x0.c
> index 83781f3..a7324ce 100644
> --- a/drivers/net/ethernet/cirrus/mac89x0.c
> +++ b/drivers/net/ethernet/cirrus/mac89x0.c
> @@ -592,10 +592,14 @@ static void set_multicast_list(struct net_devic=
e *dev)
> =C2=A0static int set_mac_address(struct net_device *dev, void *addr)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int i;
> - =C2=A0 =C2=A0 =C2=A0 printk("%s: Setting MAC address to ", dev->nam=
e);
> - =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < 6; i++)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 printk(" %2.2x", d=
ev->dev_addr[i] =3D ((unsigned char *)addr)[i]);
> - =C2=A0 =C2=A0 =C2=A0 printk(".\n");
> + =C2=A0 =C2=A0 =C2=A0 struct sockaddr *saddr =3D addr;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (!is_valid_ether_addr(addr->sa_data))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EADDRNOTAV=
AIL;
> +
> + =C2=A0 =C2=A0 =C2=A0 memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN)=
;
> + =C2=A0 =C2=A0 =C2=A0 printk("%s: Setting MAC address to %pM\n", dev=
->name, dev->dev_addr);
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* set the Ethernet address */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i=3D0; i < ETH_ALEN/2; i++)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0writereg(dev, =
PP_IA+i*2, dev->dev_addr[i*2] | (dev->dev_addr[i*2+1] << 8));

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds
