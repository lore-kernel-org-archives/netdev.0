From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] gpio: extend gpiod_get*() with flags parameter
Date: Thu, 24 Jul 2014 09:10:52 -0700
Message-ID: <20140724161052.GA15615@kroah.com>
References: <1406214298-20062-1-git-send-email-acourbot@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, Ulf Hansson <ulf.hansson@linaro.org>,
 Wolfram Sang <wsa@the-dreams.de>, linux-mmc@vger.kernel.org,
 Chris Ball <chris@printf.net>, dri-devel@lists.freedesktop.org,
 Liam Girdwood <lgirdwood@gmail.com>, Peter Ujfalusi <peter.ujfalusi@ti.com>,
 Laurent Pinchart <laurent.pinchart@ideasonboard.com>,
 Pavel Machek <pavel@ucw.cz>, Jiri Slaby <jslaby@suse.cz>, gnurou@gmail.com,
 Florian Fainelli <f.fainelli@gmail.com>, Samuel Ortiz <sameo@linux.intel.com>,
 Alexander Shiyan <shc_work@mail.ru>,
 Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
 Lee Jones <lee.jones@linaro.org>, Paul Handrigan <Paul.Handrigan@cirrus.com>,
 linux-iio@vger.kernel.org, linux-omap@vger.kernel.org,
 Tomi Valkeinen <tomi.valkeinen@ti.com>, Hans Verkuil <hans.verkuil@cisco.com>,
 linux-serial@vger.kernel.org, linux-input@vger.kernel.org,
 Jean-Christophe Plagniol-Villard <plagnioj@jcr
To: Alexandre Courbot <acourbot@nvidia.com>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
Content-Disposition: inline
In-Reply-To: <1406214298-20062-1-git-send-email-acourbot@nvidia.com>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: dri-devel-bounces@lists.freedesktop.org
Sender: "dri-devel" <dri-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

On Fri, Jul 25, 2014 at 12:04:58AM +0900, Alexandre Courbot wrote:
> The huge majority of GPIOs have their direction and initial value set
> right after being obtained by one of the gpiod_get() functions. The
> integer GPIO API had gpio_request_one() that took a convenience flags
> parameter allowing to specify an direction and value applied to the
> returned GPIO. This feature greatly simplifies client code and ensures
> errors are always handled properly.
> 
> A similar feature has been requested for the gpiod API. Since GPIOs need
> a direction to be used anyway, we prefer to extend the existing
> functions instead of introducing new functions that would raise the
> number of gpiod getters to 16 (!).
> 
> The drawback of this approach is that all gpiod clients need to be
> updated, but there aren't that many and the moment and this results in
> smaller (and hopefully safer) code.
> 
> Signed-off-by: Alexandre Courbot <acourbot@nvidia.com>
> ---
> This change will be difficult to apply without breaking things, but
> let's try to do it right. Hopefully the benefit will outweight the
> disturbance.
> 
> This is a patch against -next to list and update all current gpiod
> consumers. Updates are trivial at first sight, but it would be nice to
> get as many acks as possible from the respective subsystem maintainers.
> 
> I'm not sure how this could be applied harmlessly though - maybe through
> a dedicated branch for -next? Problem is that a lot of new code is not
> yet merged into mainline, and conflicts are very likely to occur. Linus,
> do you have any suggestion as to how this can be done without blood being
> spilled?

Do this in 3 steps, not all at once.

Make a new function that takes the new argument, get that merged

Submit patches that convert drivers over to use the new function.

Once all of those are merged, remove the old function.

That way there are no "flag days" needed, and everyone is happy you
don't send out emails with 40+ people in the To: and Cc: lines :)

thanks,

greg k-h
