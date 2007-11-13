From: Mark Lord <liml@rtr.ca>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 12:47:51 -0500
Message-ID: <4739E347.30406@rtr.ca>
References: <32209efe0711122242m3a5f081asf1c11a38b24db10c@mail.gmail.com> <20071113031553.3c7b5c16.akpm@linux-foundation.org> <4739ADA2.4060604@rtr.ca> <alpine.LFD.0.9999.0711131521590.3265@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.0.9999.0711131521590.3265@localhost.localdomain>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Gleixner wrote:
> On Tue, 13 Nov 2007, Mark Lord wrote:
..
>> I *still* get very slow resume-from-RAM quite often here
>> (new in 2.6.23 kernel, wasn't there in early 2.6.23-rc*).
..
>> Something eventually times out after a minute or so
>> and it comes back.  Cannot make it happen reliably,
>> unless I'm in a hurry to get something done.  :)
>> I suspect USB here, probably the same loopy bug that
>> we added a "loop limit failsafe" for back in 2.6.21(?).
> 
> Do you have a pointer to that please ?
..

The "limit" added in the code below,
which was for messages of this form:

    hub 1-1:1.0: hub_port_status failed (err = -71)
    last message repeated 347 times

drivers/usb/hub.c:  
> static void hub_tt_kevent (struct work_struct *work)
> {
>         struct usb_hub          *hub =
>                 container_of(work, struct usb_hub, tt.kevent);
>         unsigned long           flags;
>         int                     limit = 100;
> 
>         spin_lock_irqsave (&hub->tt.lock, flags);
>         while (--limit && !list_empty (&hub->tt.clear_list)) {
>             ...

I'm not yet sure what's happening on resume now,
but there's this huge long pause with a dark screen
and then suddenly the USB subsystem comes to life
(my mouse lights up) and the system finally resumes.

More when I know more.  But it doesn't happen every time,
or even most times, so git-bisect is not possible either.

This one actually requires a developer/maintainer to put
in some effort and think about things.  Currently, that's me.

-ml
