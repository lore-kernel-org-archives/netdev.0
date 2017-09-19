From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC PATCH 1/3] usbnet: Get rid of spammy usbnet "kevent X may have been dropped"
Date: Tue, 19 Sep 2017 19:45:58 +0200
Message-ID: <87377ioa3t.fsf@miraculix.mork.no>
References: <20170919161522.995-1-dianders@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Oliver Neukum <oneukum@suse.com>, groeck@chromium.org,
        grundler@chromium.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Douglas Anderson <dianders@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170919161522.995-1-dianders@chromium.org> (Douglas Anderson's
        message of "Tue, 19 Sep 2017 09:15:20 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Douglas Anderson <dianders@chromium.org> writes:

> Every once in a while when my system is under a bit of stress I see
> some spammy messages show up in my logs that say:
>
>   kevent X may have been dropped
>
> As far as I can tell these messages aren't terribly useful.

I agree, FWIW. These messages just confuse users for no purpose at all.


> +	/* If work is already started this will mark it to run again when it
> +	 * finishes; if we already had work pending and it hadn't started
> +	 * yet then that's fine too.
> +	 */
> +	schedule_work (&dev->kevent);
> +	netdev_dbg(dev->net, "kevent %d scheduled\n", work);

Or maybe

        if (schedule_work (&dev->kevent))
        	netdev_dbg(dev->net, "kevent %d scheduled\n", work);


?  Not that I think it matters much.


Bj=C3=B8rn
