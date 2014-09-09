From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Wed, 10 Sep 2014 00:00:31 +0200 (CEST)
Message-ID: <alpine.LRH.2.00.1409092355130.14816@twin.jikos.cz>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com> <CAB=NE6Wti1RpAFk5q_YeZn2F9Rd=wsiwhyPszu74nG9fXwH5vQ@mail.gmail.com> <20140905141241.GC10455@mtj.dyndns.org> <20140905164405.GA28964@core.coreip.homeip.net> <20140905174925.GA12991@mtj.dyndns.org>
 <CAB=NE6VPTV39pNujOgO422wbUvU44HZ7s=aaxPVraNECqA6e4Q@mail.gmail.com> <20140905224047.GC15723@mtj.dyndns.org> <CAB=NE6Uz1VD5qpMFSBfQRV8ih9FQcCUhNtWMvD38t5hdDvix4Q@mail.gmail.com> <20140909011059.GB11706@mtj.dyndns.org> <1410241109.2028.22.camel@jarvis.lan>
 <CAB=NE6WGAMvffGDTkN5x5Cd+YOtD-Cmo3v7_8FmJ5cvCRbFEpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>,
	Tejun Heo <tj@kernel.org>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay@vrfy.org>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Wu Zhangjin <falcon@meizu.com>, Takashi Iwai <tiwai@suse.de>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Oleg Nesterov <oleg@redhat.com>, hare@suse.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	Santosh Rastapur <santosh@chelsio.com>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:57333 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751950AbaIIWAm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2014 18:00:42 -0400
In-Reply-To: <CAB=NE6WGAMvffGDTkN5x5Cd+YOtD-Cmo3v7_8FmJ5cvCRbFEpw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 9 Sep 2014, Luis R. Rodriguez wrote:

> By design it seems systemd should not allow worker processes to block
> indefinitely and in fact it currently uses the same timeout for all
> types of worker processes. 

And I whole-heartedly believe this is something that fundamentally needs 
to be addressed in systemd, not in the kernel.

This aproach is actually introducing a user-visible regressions. Look, for 
example, exec() never times out. Therefore if your system is on its knees, 
heavily overloaded (or completely broken), you are likely to be able to 
`reboot' it, because exec("/sbin/reboot") ultimately succeeds.

But with all the timeouts, dbus, "Failed to issue method call: Did 
not receive a reply" messages, this is getting close to impossible.

-- 
Jiri Kosina
SUSE Labs
