From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: [PATCH 2/2] isdn: hisax: isac: fixed code style issues.
Date: Sun, 13 Mar 2016 21:56:38 +0200
Message-ID: <CAEnQRZCi5K5QXJwwUyeNK0=D_8vPPRvQo1V_1Of67yXyQS_GDw@mail.gmail.com>
References: <1457896913-5406-1-git-send-email-gabrielcsmo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: isdn@linux-pingi.de,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Cosmin-Gabriel Samoila <gabrielcsmo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33982 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821AbcCMT4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 15:56:40 -0400
In-Reply-To: <1457896913-5406-1-git-send-email-gabrielcsmo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 13, 2016 at 9:21 PM, Cosmin-Gabriel Samoila
<gabrielcsmo@gmail.com> wrote:
> Fixed errors and warnings reported by checkpatch.pl.
>

Use indicative mood in your commit message.

So, s/Fixed/Fix.

http://chris.beams.io/posts/git-commit/

> Signed-off-by: Cosmin-Gabriel Samoila <gabrielcsmo@gmail.com>
> ---
>  drivers/isdn/hisax/isac.c | 32 ++++++++++++++++++--------------
>  1 file changed, 18 insertions(+), 14 deletions(-)
>
> diff --git a/drivers/isdn/hisax/isac.c b/drivers/isdn/hisax/isac.c
> index 7fdf78f..419abe1 100644
> --- a/drivers/isdn/hisax/isac.c
> +++ b/drivers/isdn/hisax/isac.c
> @@ -24,9 +24,8 @@
>  #define DBUSY_TIMER_VALUE 80
>  #define ARCOFI_USE 1
>
> -static char *ISACVer[] =
> -{"2086/2186 V1.1", "2085 B1", "2085 B2",
> - "2085 V2.3"};
> +static char *ISACVer[] = {"2086/2186 V1.1", "2085 B1", "2085 B2",
> +"2085 V2.3"};
>
>  void ISACVersion(struct IsdnCardState *cs, char *s)
>  {
> @@ -215,9 +214,11 @@ isac_interrupt(struct IsdnCardState *cs, u_char val)
>                         if (count == 0)
>                                 count = 32;
>                         isac_empty_fifo(cs, count);
> -                       if ((count = cs->rcvidx) > 0) {
> +                       count = cs->rcvidx;
> +                       if (count > 0) {
>                                 cs->rcvidx = 0;
> -                               if (!(skb = alloc_skb(count, GFP_ATOMIC)))
> +                               skb = alloc_skb(count, GFP_ATOMIC);
> +                               if (!skb)
>                                         printk(KERN_WARNING "HiSax: D receive out of memory\n");
>                                 else {
>                                         memcpy(skb_put(skb, count), cs->rcvbuf, count);
> @@ -251,11 +252,12 @@ isac_interrupt(struct IsdnCardState *cs, u_char val)
>                                 cs->tx_skb = NULL;
>                         }
>                 }
> -               if ((cs->tx_skb = skb_dequeue(&cs->sq))) {
> +               cs->tx_skb = skb_dequeue(&cs->sq);
> +               if (cs->tx_skb) {
>                         cs->tx_cnt = 0;
>                         isac_fill_fifo(cs);
> -               } else
> -                       schedule_event(cs, D_XMTBUFREADY);
> +               }
> +               schedule_event(cs, D_XMTBUFREADY);
>         }
>  afterXPR:
>         if (val & 0x04) {       /* CISQ */
> @@ -313,7 +315,8 @@ afterXPR:
>  #if ARCOFI_USE
>                         if (v1 & 0x08) {
>                                 if (!cs->dc.isac.mon_rx) {
> -                                       if (!(cs->dc.isac.mon_rx = kmalloc(MAX_MON_FRAME, GFP_ATOMIC))) {
> +                                       cs->dc.isac.mon_rx = kmalloc(MAX_MON_FRAME, GFP_ATOMIC);
> +                                       if (!cs->dc.isac.mon_rx) {
>                                                 if (cs->debug & L1_DEB_WARN)
>                                                         debugl1(cs, "ISAC MON RX out of memory!");
>                                                 cs->dc.isac.mocr &= 0xf0;
> @@ -340,10 +343,11 @@ afterXPR:
>                                         cs->writeisac(cs, ISAC_MOCR, cs->dc.isac.mocr);
>                                 }
>                         }
> -               afterMONR0:
> +afterMONR0:
>                         if (v1 & 0x80) {
>                                 if (!cs->dc.isac.mon_rx) {
> -                                       if (!(cs->dc.isac.mon_rx = kmalloc(MAX_MON_FRAME, GFP_ATOMIC))) {
> +                                       cs->dc.isac.mon_rx = kmalloc(MAX_MON_FRAME, GFP_ATOMIC);
> +                                       if (!cs->dc.isac.mon_rx) {
>                                                 if (cs->debug & L1_DEB_WARN)
>                                                         debugl1(cs, "ISAC MON RX out of memory!");
>                                                 cs->dc.isac.mocr &= 0x0f;
> @@ -368,7 +372,7 @@ afterXPR:
>                                 cs->dc.isac.mocr |= 0x40;
>                                 cs->writeisac(cs, ISAC_MOCR, cs->dc.isac.mocr);
>                         }
> -               afterMONR1:
> +afterMONR1:
>                         if (v1 & 0x04) {
>                                 cs->dc.isac.mocr &= 0xf0;
>                                 cs->writeisac(cs, ISAC_MOCR, cs->dc.isac.mocr);
> @@ -405,7 +409,7 @@ afterXPR:
>                                 if (cs->debug & L1_DEB_MONITOR)
>                                         debugl1(cs, "ISAC %02x -> MOX0", cs->dc.isac.mon_tx[cs->dc.isac.mon_txp - 1]);
>                         }
> -               AfterMOX0:
> +AfterMOX0:
>                         if (v1 & 0x20) {
>                                 if ((!cs->dc.isac.mon_tx) || (cs->dc.isac.mon_txc &&
>                                                               (cs->dc.isac.mon_txp >= cs->dc.isac.mon_txc) &&
> @@ -428,7 +432,7 @@ afterXPR:
>                                 if (cs->debug & L1_DEB_MONITOR)
>                                         debugl1(cs, "ISAC %02x -> MOX1", cs->dc.isac.mon_tx[cs->dc.isac.mon_txp - 1]);
>                         }
> -               AfterMOX1:;
> +AfterMOX1:;
>  #endif
>                 }
>         }
> --
> 1.9.1
>
