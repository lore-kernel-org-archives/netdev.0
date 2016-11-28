From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v4 0/4] Fix OdroidC2 Gigabit Tx link issue
Date: Mon, 28 Nov 2016 09:54:28 -0800
Message-ID: <049b1efc-3bad-92e0-45ef-0563dc5d81de@gmail.com>
References: <1480348229-25672-1-git-send-email-jbrunet@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Carlo Caione <carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org>,
        Kevin Hilman <khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        Andre Roth <neolynx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>,
        Yegor Yefremov <yegorslists-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        =?UTF-8?Q?Andreas_F=c3=a4rber?= <afaerber-l3A5Bk7waGM@public.gmane.org>
To: Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1480348229-25672-1-git-send-email-jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/28/2016 07:50 AM, Jerome Brunet wrote:
> This patchset fixes an issue with the OdroidC2 board (DWMAC + RTL8211F).
> The platform seems to enter LPI on the Rx path too often while performing
> relatively high TX transfer. This eventually break the link (both Tx and
> Rx), and require to bring the interface down and up again to get the Rx
> path working again.
> 
> The root cause of this issue is not fully understood yet but disabling EEE
> advertisement on the PHY prevent this feature to be negotiated.
> With this change, the link is stable and reliable, with the expected
> throughput performance.
> 
> The patchset adds options in the generic phy driver to disable EEE
> advertisement, through device tree. The way it is done is very similar
> to the handling of the max-speed property.
> 
> Patch 4 is provided here for testing purpose only. Please don't merge
> patch 4, this change will go through the amlogic's tree.

Sorry, but I really don't like the route this is going, and I should
have made myself clearer before on that, I really think utilizing a PHY
fixup is more appropriate here than an extremely generic DT property.
The fixup code can be in the affected PHY driver, or it can be somewhere
else, your call. There is no shortage of option on how to implement it,
and this would be something easy to enable/disable for known good
configurations (ala PCI/USB fixups).

If we start supporting generic "enable", "disable" type of properties
with values that map directly to register definitions of the HW, we
leave too much room for these properties to be utilized to implement a
specific policy, and this is not acceptable.
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
