From: "=?ISO-8859-2?Q?Marcin_=A6lusarz?=" <marcin.slusarz@gmail.com>
Subject: Re: 2.6.23-rc2: WARNING: at kernel/irq/resend.c:70 check_irq_resend()
Date: Mon, 13 Aug 2007 09:13:50 +0200
Message-ID: <4bacf17f0708130013m67dcf91fx7136d0050aa08b82@mail.gmail.com>
References: <18107.11431.838905.331157@stoffel.org>
	 <1186733140.12828.45.camel@chaos> <20070810082346.GD1764@ff.dom.local>
	 <20070810083050.GA4545@elte.hu> <20070810084924.GF1764@ff.dom.local>
	 <20070810085611.GA11639@elte.hu> <20070810091231.GH1764@ff.dom.local>
	 <20070810093353.GA19777@elte.hu> <20070810100513.GA3279@ff.dom.local>
	 <20070810101641.GA31396@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@o2.pl>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"John Stoffel" <john@stoffel.org>, linux-kernel@vger.kernel.org,
	shemminger@linux-foundation.org, vignaud@xandmail.fr,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: "Ingo Molnar" <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:47072 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S940816AbXHMHNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2007 03:13:51 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1755516wah
        for <netdev@vger.kernel.org>; Mon, 13 Aug 2007 00:13:51 -0700 (PDT)
In-Reply-To: <20070810101641.GA31396@elte.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/8/10, Ingo Molnar <mingo@elte.hu>:
> Index: linux/arch/i386/kernel/io_apic.c
> ===================================================================
> --- linux.orig/arch/i386/kernel/io_apic.c
> +++ linux/arch/i386/kernel/io_apic.c
> @@ -735,7 +735,8 @@ void fastcall send_IPI_self(int vector)
>          * Wait for idle.
>          */
>         apic_wait_icr_idle();
> -       cfg = APIC_DM_FIXED | APIC_DEST_SELF | vector | APIC_DEST_LOGICAL;
> +       cfg = APIC_DM_FIXED | APIC_DEST_SELF | vector | APIC_DEST_LOGICAL |
> +               APIC_INT_LEVELTRIG;
>         /*
>          * Send the IPI. The write to APIC_ICR fires this off.
>          */
> Index: linux/arch/x86_64/kernel/genapic.c
> ===================================================================
> --- linux.orig/arch/x86_64/kernel/genapic.c
> +++ linux/arch/x86_64/kernel/genapic.c
> @@ -62,5 +62,6 @@ void __init setup_apic_routing(void)
>
>  void send_IPI_self(int vector)
>  {
> -       __send_IPI_shortcut(APIC_DEST_SELF, vector, APIC_DEST_PHYSICAL);
> +       __send_IPI_shortcut(APIC_DEST_SELF, vector, APIC_DEST_PHYSICAL |
> +                           APIC_INT_LEVELTRIG);
>  }
>
network card timed out as usual ;)

Marcin
