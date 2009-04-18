From: leiming <tom.leiming@gmail.com>
Subject: Re: 2.6.30-rc2-git2: Reported regressions from 2.6.29
Date: Sat, 18 Apr 2009 11:50:51 +0800
Message-ID: <20090418115051.175f292f@linux-lm>
References: <EJaiQ4Wfaz.A.3YG.4v85JB@chimera>
	<d82e647a0904161837w6b6fb652la0da05f9061e95dc@mail.gmail.com>
	<200904172336.12414.rjw@sisk.pl>
	<20090418103226.54250420@linux-lm>
	<alpine.LFD.2.00.0904171952260.4042@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	video4linux-list@redhat.com, laurent.pinchart@skynet.be,
	mchehab@infradead.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.0904171952260.4042@localhost.localdomain>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Apr 2009 19:55:29 -0700 (PDT)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> @@ -742,7 +742,7 @@ static int uvc_alloc_urb_buffers(struct
> > uvc_video_device *video, 
> >  	/* Buffers are already allocated, bail out. */
> >  	if (video->urb_size)
> > -		return 0;
> > +		return DIV_ROUND_UP(video->urb_size, psize);
> 
> I don't think this is right. It should round _down_.
> 
> It's supposed to return 'npackets', but if you pass it a different
> packet size than it was passed originally, it can now return a

Now uvc only uses the previous allocated buffer in suspend/resume
path, so the packet size doen't change in this path.

> potentially bigger number than the already allocated buffer, no?

If this case does exist, the URBs need to be updated and the patch is 
not enough. 

> 
> So I think it should round down (ie use a regular divide). No?

Because the following fact:

	uvc_alloc_urb_buffers()
	{
		...
		video->urb_size = psize * npackets; 
		...
	}

so DIV_ROUND_UP still can work correctly.

Thanks!

-- 
Lei Ming
