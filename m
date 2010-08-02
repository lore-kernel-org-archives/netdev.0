From: Komuro <komurojun-mbn@nifty.com>
Subject: Re: [PATCH 01/11] pcmcia: use pcmica_{read,write}_config_byte
Date: Mon, 2 Aug 2010 20:59:26 +0900 (JST)
Message-ID: <15238373.192661280750366920.komurojun-mbn@nifty.com>
References: <1280667550-3040-1-git-send-email-linux@dominikbrodowski.net>
	<20100801125749.GA2564@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	linux-pcmcia@lists.infradead.org, linux-wireless@vger.kernel.org,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	linux-serial@vger.kernel.org
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org>
In-Reply-To: <1280667550-3040-1-git-send-email-linux@dominikbrodowski.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-pcmcia>,
	<mailto:linux-pcmcia-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-pcmcia/>
List-Post: <mailto:linux-pcmcia@lists.infradead.org>
List-Help: <mailto:linux-pcmcia-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-pcmcia>,
	<mailto:linux-pcmcia-request@lists.infradead.org?subject=subscribe>
Sender: linux-pcmcia-bounces@lists.infradead.org
Errors-To: linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi,

>--- a/drivers/net/pcmcia/xirc2ps_cs.c
>+++ b/drivers/net/pcmcia/xirc2ps_cs.c


>+	if (err)
> 	    goto config_error;
>-	reg.Action = CS_WRITE;
>-	reg.Offset = CISREG_IOBASE_1;
>-	reg.Value = (link->io.BasePort2 >> 8) & 0xff;
>-	if ((err = pcmcia_access_configuration_register(link, &reg)))
>+
>+	err = pcmcia_write_config_byte(link, CISREG_IOBASE_1,
>+				link->io.BasePort2 & 0xff);

It should be

	err = pcmcia_write_config_byte(link, CISREG_IOBASE_1,
				(link->io.BasePort2 >> 8) & 0xff);
