From: Robert Jarzmik <robert.jarzmik-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH v2 1/3] net: smc91x: isolate u16 writes alignment workaround
Date: Sat, 15 Oct 2016 23:11:56 +0200
Message-ID: <87shrx5nc3.fsf@belgarion.home>
References: <1476559670-25056-1-git-send-email-robert.jarzmik@free.fr>
        <1476559670-25056-2-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Nicolas Pitre <nico-vtqb6HGKxmzR7s880joybQ@public.gmane.org>,
        Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476559670-25056-2-git-send-email-robert.jarzmik-GANU6spQydw@public.gmane.org>
        (Robert Jarzmik's message of "Sat, 15 Oct 2016 21:27:48 +0200")
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sorry David, I just noticed you weren't in the "To:" of this serie, but I won't
forget you for the v3 I need to release anyway
(https://lkml.org/lkml/2016/10/15/104).

Robert Jarzmik <robert.jarzmik-GANU6spQydw@public.gmane.org> writes:
> +	lp->half_word_align4 =
> +		machine_is_mainstone() || machine_is_stargate2() ||
> +		machine_is_pxa_idp();

Bah this one is not good enough.

First, machine_is_*() is not defined if CONFIG_ARM=n, and this part is not under
a #ifdef CONFIG_ARM.

Moreover, I think it is a good occasion to go further, and :
 - enhance smc91x_platdata and add a pxa_u16_align4 boolean
 - transform this statement into :
	lp->half_word_align4 = lp->cfg.pxa_u16_align4

This will remove the machine_*() calls from the smc91x driver, which looks a
good move, doesn't it ?

Cheers.

--
Robert
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
