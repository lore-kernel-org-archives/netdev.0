From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [RFC PATCH 2/3] usbnet: Avoid potential races in
 usbnet_deferred_kevent()
Date: Wed, 20 Sep 2017 10:23:30 +0200
Message-ID: <1505895810.27967.1.camel@suse.com>
References: <20170919161522.995-1-dianders@chromium.org>
         <20170919161522.995-2-dianders@chromium.org>
         <1505853476.15836.9.camel@suse.com>
         <CABXOdTdnaf5REYjgtR6+hoRhiB2c=xb+1CxMmv7XsukYDFDitA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Douglas Anderson <dianders@chromium.org>,
        Guenter Roeck <groeck@chromium.org>,
        Grant Grundler <grundler@chromium.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Guenter Roeck <groeck@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CABXOdTdnaf5REYjgtR6+hoRhiB2c=xb+1CxMmv7XsukYDFDitA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag, den 19.09.2017, 13:51 -0700 schrieb Guenter Roeck:
> On Tue, Sep 19, 2017 at 1:37 PM, Oliver Neukum <oneukum@suse.com> wrote:
> > 
> > Am Dienstag, den 19.09.2017, 09:15 -0700 schrieb Douglas Anderson:
> > > 
[..]
> > > NOTES:
> > > - No known bugs are fixed by this; it's just found by code inspection.
> > 
> > Hi,
> > 
> > unfortunately the patch is wrong. The flags must be cleared only
> > in case the handler is successful. That is not guaranteed.
> > 
> 
> Just out of curiosity, what is the retry mechanism ? Whenever a new,
> possibly unrelated, event is scheduled ?

Hi,

that actually depends on the flag.
Look at the case of fail_lowmem. There we reschedule.

	HTH
		Oliver
