From: Pali =?ISO-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Subject: Re: wl1251 & mac address & calibration data
Date: Thu, 15 Dec 2016 16:33:37 +0100
Message-ID: <1481816017.2090.2.camel@Pali-Nokia-N900>
References: <201611111820.52072@pali> <201611241749.33681@pali>
         <20161124181138.4i6ehkpohjxfgpbn@earth> <201611241935.32796@pali>
          <87d1gtli57.fsf@purkki.adurom.net>
Reply-To: Pali =?ISO-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Sebastian Reichel <sre@kernel.org>, Pavel Machek <pavel@ucw.cz>,
        Michal Kazior <michal.kazior@tieto.com>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Tony Lindgren <tony@atomide.com>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org,
        "Luis R. Rodriguez" <mcgrof@kernel.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87d1gtli57.fsf@purkki.adurom.net>
Content-ID: <1481816016.2090.1.camel@Pali-Nokia-N900>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu Dec 15 09:18:44 2016 Kalle Valo <kvalo@codeaurora.org> wrote:
> (Adding Luis because he has been working on request_firmware() lately)
> 
> Pali Rohár <pali.rohar@gmail.com> writes:
> 
> > > > So no, there is no argument against... request_firmware() in
> > > > fallback mode with userspace helper is by design blocking and
> > > > waiting for userspace. But waiting for some change in DTS in
> > > > kernel is just nonsense.
> > > 
> > > I would just mark the wlan device with status = "disabled" and
> > > enable it in the overlay together with adding the NVS & MAC info.
> > 
> > So if you think that this solution make sense, we can wait what net 
> > wireless maintainers say about it...
> > 
> > For me it looks like that solution can be:
> > 
> > extending request_firmware() to use only userspace helper
> 
> I haven't followed the discussion very closely but this is my preference
> what drivers should do:
> 
> 1) First the driver should do try to get the calibration data and mac
>       address from the device tree.
> 

Ok, but there is no (dynamic, device specific) data in DTS for N900. So 1) is noop.

> 2) If they are not in DT the driver should retrieve the calibration data
>       with request_firmware(). BUT with an option for user space to
>       implement that with a helper script so that the data can be created
>       dynamically, which I believe openwrt does with ath10k calibration
>       data right now.

Currently there is flag for request_firmware() that it should fallback to user helper if direct VFS access not find needed firmware.

But this flag is not suitable as /lib/firmware already provides default (not device specific) calibration data.

So I would suggest to add another flag/function which will primary use user helper.

> > and load mac address also via request_firmware() either by appending
> > it   into NVS data or via separate call
> 
> I'm not really fan of the idea providing permanent mac address through
> request_firmware(). For example, how to handle multiple devices on the
> same host, would there be a need for some kind of bus ids encoded to the
> filename? And what about devices with multiple mac addresses?

For N900 there is only one wl1251 device. And... wl12xx is already using appended MAC address in calibration data read by request firmware. So reason why I prefer similar usage also for wl1251.

> I wish there would be a better way than request_firmware() to provide
> the permanent mac addresses from user space (if device tree is not
> available), I just don't know what that could be :) But if we would
> start to use request_firmware() for this at least there should be a
> wider concensus about that and it should be properly documented, just
> like the device tree bindings.
> 
> -- 
> Kalle Valo

I do not know about any other, so reason why I'm asking :-) and there are my proposed solutions. If you (or any other) came up with better we can discuss about it :-)

-- 
Pali Rohár
pali.rohar@gmail.com
