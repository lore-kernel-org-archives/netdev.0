From: Peter Rosin <peda-koto5C5qi+TLoDKTGw+V6w@public.gmane.org>
Subject: [PATCH 0/2] register atmel-ssc as sound DAI w/o platform driver
Date: Thu, 1 Dec 2016 12:59:07 +0100
Message-ID: <1480593549-6464-1-git-send-email-peda@axentia.se>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Rosin <peda-koto5C5qi+TLoDKTGw+V6w@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Liam Girdwood <lgirdwood-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Jaroslav Kysela <perex-/Fr2/VpizcU@public.gmane.org>,
        Takashi Iwai <tiwai-IBi9RG/b67k@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org>,
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi!

The Atmel SSC is currently not usable as an audio DAI unless someone
registers it with ASoC. This is currently delegated to a platform
driver for every possible audio use, and prevents the SSC from being
used as a cpu DAI with the simple-audio-card driver.

The first patch fixes this.

The second patch simplifies one of these platform drivers, since it
can now rely on the SSC to register itself with ASoC. However, this
may not be a possible simplification for other, older, drivers since
it also requires device tree changes.

Cheers,
Peter

Peter Rosin (2):
  misc: atmel-ssc: register as sound DAI if #sound-dai-cells is present
  ASoC: atmel: tse850: rely on the ssc to register as a cpu dai by
    itself

 .../devicetree/bindings/misc/atmel-ssc.txt         |  2 +
 .../bindings/sound/axentia,tse850-pcm5142.txt      |  5 +--
 drivers/misc/atmel-ssc.c                           | 50 ++++++++++++++++++++++
 include/linux/atmel-ssc.h                          |  1 +
 sound/soc/atmel/tse850-pcm5142.c                   | 23 ++--------
 5 files changed, 58 insertions(+), 23 deletions(-)

-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
