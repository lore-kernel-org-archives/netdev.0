From: Borislav Petkov <bp@alien8.de>
Subject: Re: Re: Re: Re: Re: Re: A reliable kernel panic (3.6.2) and system
 crash when visiting a particular website
Date: Sun, 21 Oct 2012 22:36:47 +0200
Message-ID: <20121021203647.GA13365@liondog.tnic>
References: <966148591.30347.1350754909449.JavaMail.mail@webmail08>
 <20121020203227.GC555@elf.ucw.cz>
 <20121020225849.GA8976@liondog.tnic>
 <1781795634.31179.1350774917965.JavaMail.mail@webmail04>
 <20121021002424.GA16247@liondog.tnic>
 <1798605268.19162.1350784641831.JavaMail.mail@webmail17>
 <20121021110851.GA6504@liondog.tnic>
 <121566322.100103.1350820776893.JavaMail.mail@webmail20>
 <20121021170315.GB20642@liondog.tnic>
 <1906833625.122006.1350848941352.JavaMail.mail@webmail16>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: pavel@ucw.cz, linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org, linux-media@vger.kernel.org,
	linux-usb@vger.kernel.org, zonque@gmail.com,
	alsa-devel@alsa-project.org, stern@rowland.harvard.edu
To: "Artem S. Tashkinov" <t.artem@lycos.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1906833625.122006.1350848941352.JavaMail.mail@webmail16>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 21, 2012 at 07:49:01PM +0000, Artem S. Tashkinov wrote:
> I ran it this way: while :; do dmesg -c; done | scat /dev/sda11 (yes,
> straight to a hdd partition to eliminate a FS cache)

Well, I'm no fs guy but this should still go through the buffer cache. I
think the O_SYNC flag makes sure it all lands on the partition in time.
Oh well, it doesn't matter.

> Don't judge me harshly - I'm not a programmer.

If you wrote that and you're not a programmer, it certainly looks cool,
good job!.

 [ Btw, don't forget to free(buffer) at the end. ]

Also, there was a patchset recently which added a blockconsole method to
the kernel with which you can do something like that in a generic way.

Back to the issue at hand: it looks like ehci_hcd is causing some list
corruptions, maybe coming from the uvcvideo or whatever. I think the usb
people will have a better idea.

Btw, is there any particular reason you're running a 32-bit kernel?

Thanks.

-- 
Regards/Gruss,
    Boris.
