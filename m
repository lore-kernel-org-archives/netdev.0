From: Zach Brown <zach.brown@ni.com>
Subject: Re: [PATCH v4 1/3] skge: Rename LED_OFF and LED_ON in marvel skge
 driver to avoid conflicts with leds namespace
Date: Tue, 11 Oct 2016 16:29:39 -0500
Message-ID: <20161011212938.GA24636@zach-desktop>
References: <1476217580-21229-1-git-send-email-zach.brown@ni.com>
 <1476217580-21229-2-git-send-email-zach.brown@ni.com>
 <20161011141407.3b233e83@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, florian.c.schilhabel@googlemail.com,
 f.fainelli@gmail.com, andrew@lunn.ch, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, rpurdie@rpsys.net, gregkh@linuxfoundation.org,
 Larry.Finger@lwfinger.net, j.anaszewski@samsung.com,
 linux-leds@vger.kernel.org, mlindner@marvell.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20161011141407.3b233e83@xeon-e3>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Tue, Oct 11, 2016 at 02:14:07PM -0700, Stephen Hemminger wrote:
> On Tue, 11 Oct 2016 15:26:18 -0500
> Zach Brown <zach.brown@ni.com> wrote:
>
> > Adding led support for phy causes namespace conflicts for some
> > phy drivers.
> >
> > The marvel skge driver declared an enum for representing the states of
> > Link LED Register. The enum contained constant LED_OFF which conflicted
> > with declartation found in linux/leds.h.
> > LED_OFF changed to LED_REG_OFF
> > Also changed LED_ON to LED_REG_ON to avoid possible future conflict and
> > for consistency.
> >
> > Signed-off-by: Zach Brown <zach.brown@ni.com>
>
> Sure, that's fine but not sure why skge would be including linux/leds.h
> anyway.

It's pretty convoluted. Here's the chain of includes.
skge -> netdevice -> dsa -> phy -> phy_led_triggers -> leds
