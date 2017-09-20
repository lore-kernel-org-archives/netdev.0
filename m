From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [RFC PATCH 2/3] usbnet: Avoid potential races in
 usbnet_deferred_kevent()
Date: Wed, 20 Sep 2017 10:25:46 +0200
Message-ID: <1505895946.27967.3.camel@suse.com>
References: <20170919161522.995-1-dianders@chromium.org>
         <20170919161522.995-2-dianders@chromium.org>
         <1505853476.15836.9.camel@suse.com>
         <CAD=FV=WJOrpEqpUGA3EL5BMQTMN9NVgekd7qBX+u=gX90eRGyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Guenter Roeck <groeck@chromium.org>,
        Grant Grundler <grundler@chromium.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
        netdev@vger.kernel.org
To: Doug Anderson <dianders@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAD=FV=WJOrpEqpUGA3EL5BMQTMN9NVgekd7qBX+u=gX90eRGyA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag, den 19.09.2017, 13:53 -0700 schrieb Doug Anderson:
> Hi,
> 
> On Tue, Sep 19, 2017 at 1:37 PM, Oliver Neukum <oneukum@suse.com> wrote:
> > 
> > Am Dienstag, den 19.09.2017, 09:15 -0700 schrieb Douglas Anderson:
> > > 
> > > In general when you've got a flag communicating that "something needs
> > > to be done" you want to clear that flag _before_ doing the task.  If
> > > you clear the flag _after_ doing the task you end up with the risk
> > > that this will happen:
> > > 
> > > 1. Requester sets flag saying task A needs to be done.
> > > 2. Worker comes and stars doing task A.
> > > 3. Worker finishes task A but hasn't yet cleared the flag.
> > > 4. Requester wants to set flag saying task A needs to be done again.
> > > 5. Worker clears the flag without doing anything.
> > > 
> > > Let's make the usbnet codebase consistently clear the flag _before_ it
> > > does the requested work.  That way if there's another request to do
> > > the work while the work is already in progress it won't be lost.
> > > 
> > > NOTES:
> > > - No known bugs are fixed by this; it's just found by code inspection.
> > 
> > Hi,
> > 
> > unfortunately the patch is wrong. The flags must be cleared only
> > in case the handler is successful. That is not guaranteed.
> > 
> >         Regards
> >                 Oliver
> > 
> > NACK
> 
> OK, thanks for reviewing!  I definitely wasn't super confident about
> the patch (hence the RFC).
> 
> Do you think that the races I identified are possible to hit?  In

As far as I can tell, we are safe, but you are right to say that the
driver is not quite clean at that point.

> other words: should I try to rework the patch somehow or just drop it?
>  Originally I had the patch setting the flags back to true in the
> failure cases, but then I convinced myself that wasn't needed.  I can
> certainly go back and try it that way...

Setting the flags again in the error case would certainly be an
improvement. I'd be happy with a patch doing that.

	Regards
		Oliver
