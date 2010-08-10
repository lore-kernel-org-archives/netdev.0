From: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 1/1] Bluetooth: hidp: Add support for hidraw    
 HIDIOCGFEATURE  and HIDIOCSFEATURE
Date: Tue, 10 Aug 2010 13:46:51 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1008101344480.29919@pobox.suse.cz>
References: <1276467601-9066-1-git-send-email-alan@signal11.us>  <1278623485.10421.73.camel@localhost.localdomain>  <4C369CDC.9080104@signal11.us>  <1278662497.10421.94.camel@localhost.localdomain>  <4C371DE8.9020002@signal11.us>  <1278680790.10421.106.camel@localhost.localdomain>
  <4C372CEE.3070109@signal11.us>  <1278696815.10421.137.camel@localhost.localdomain>  <alpine.LNX.2.00.1007221612450.4741@pobox.suse.cz> <1279812115.2621.6.camel@localhost.localdomain> <4C4878C2.9000903@signal11.us>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	David S Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Michael Poole <mdpoole-IZmAEv5cUt1AfugRpC6u6w@public.gmane.org>,
	Bastien Nocera <hadess-0MeiytkfxGOsTnJN9+BGXg@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4C4878C2.9000903-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Jul 2010, Alan Ott wrote:

> > that the ioctl() API is synchronous is fine to me, however pushing that
> > down to the transport drivers seems wrong to me. I think the HID core
> > should be able to handle a fully asynchronous transport driver. I know
> > that with the USB subsystem you are little bit spoiled here, but for
> > Bluetooth it is not the case. And in the end even using the asynchronous
> > USB URB calls would be nice as well.
> >    
> 
> How are the URB calls better than using the synchronous calls? (see below)

Hi,

I think this was the last mail in the thread so far, right?

> > So why not make the core actually wait for responses from the transport
> > driver.
> 
> Because this makes the USB side a lot more complicated, and it would 
> introduce transport specific code into the core. Further, it would 
> involve the transport driver calling hidraw with _every_ single packet 
> it receives. Further, it would have to call hidraw with HANDSHAKE 
> protocol error packets as well.
>
> >   I would make the transport drivers a lot simpler in the long
> > run.
> 
> It would make the USB transport driver and drivers/hid/hidraw much more
> complicated right now, at the expense of making the BT transport driver
> marginally simpler (and I'm not even convinced whether it would really be
> simpler). (see below for more)

Seconded.

> >   And I know that most likely besides Bluetooth and USB you won't see
> > another, but you never know.
> > 
> I just don't understand the objection. In each transport type, the waiting
> will have to be done in a different way. USB and BT are different enough that
> this is the case already, without having to imagine future buses which use
> HID. In BT, you have to check each packet which comes back from the BT network
> to see whether it is the response packet that hidraw is waiting for. Further,
> you have to check for HANDSHAKE packets indicating protocol error. Where
> better for this to be done than in hidp? Further, how can this possibly happen
> in drivers/hid/hidraw, as it doesn't know about the details of bluetooth to
> make this determination, and why should it? In my last email (
> http://lkml.org/lkml/2010/7/9/231 ) to which I got no response, I laid out how
> doing the blocking in drivers/hid/hidraw would only make all the parts except
> bluetooth more complicated (including the core, and the USB side), and would
> also introduce bluetooth-specific things into the core.
> 
> Further, you're saying that using the asynchronous USB URB calls would be a
> benefit. How is it a benefit to replace a single function call which does
> exactly what I want, with a set of asynchronous calls and then adding my own
> blocking to make it do the same thing? This sounds to me like it would be 1:
> more text, 2: duplication of code, 3: error prone. I can't understand how this
> is of benefit. Please explain to me what I'm missing.
> 
> In theory, what you're saying makes sense. Making common code and logic
> actually common is always good. In practice though, in this case, I submit
> that there really isn't any commonality, and the only way for there to be
> commonality is to do the USB side the hard way. Further, drivers/hid/hidraw
> can't wait for a bluetooth packet without having code that's
> bluetooth-specific. It seems just that simple to me.
> 
> I'll give it some more thought, and take another look at the code to see if
> there's something obvious that I'm missing. If you know what I'm missing in my
> understanding of the problem, please tell me :)

Marcel, did you have time to review Alan's explanation a little bit?

I must say I would really like to have this feature merged, but of course 
not if you completely disagree .. but then we'll have to find some 
consensus. Currently Alan's summary above quite aligns with my opinion.

Thanks,

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
