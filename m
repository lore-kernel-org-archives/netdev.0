From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Mon, 08 Sep 2014 22:38:29 -0700
Message-ID: <1410241109.2028.22.camel@jarvis.lan>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com>
	 <CAB=NE6Wti1RpAFk5q_YeZn2F9Rd=wsiwhyPszu74nG9fXwH5vQ@mail.gmail.com>
	 <20140905141241.GC10455@mtj.dyndns.org>
	 <20140905164405.GA28964@core.coreip.homeip.net>
	 <20140905174925.GA12991@mtj.dyndns.org>
	 <CAB=NE6VPTV39pNujOgO422wbUvU44HZ7s=aaxPVraNECqA6e4Q@mail.gmail.com>
	 <20140905224047.GC15723@mtj.dyndns.org>
	 <CAB=NE6Uz1VD5qpMFSBfQRV8ih9FQcCUhNtWMvD38t5hdDvix4Q@mail.gmail.com>
	 <20140909011059.GB11706@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
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
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <pravee
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140909011059.GB11706@mtj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-09-09 at 10:10 +0900, Tejun Heo wrote:
> Hello, Luis.
> 
> On Mon, Sep 08, 2014 at 06:04:23PM -0700, Luis R. Rodriguez wrote:
> > > I have no idea how the selection should be.  It could be per-insmod or
> > > maybe just a system-wide flag with explicit exceptions marked on
> > > drivers is good enough.  I don't know.
> > 
> > Its perfectly understandable if we don't know what path to take yet
> > and its also understandable for it to take time to figure out --
> > meanwhile though systemd already has merged a policy of a 30 second
> > timeout for *all drivers* though so we therefore need:
> 
> I'm not too convinced this is such a difficult problem to figure out.
> We already have most of logic in place and the only thing missing is
> how to switch it.  Wouldn't something like the following work?
> 
> * Add a sysctl knob to enable asynchronous device probing on module
>   load and enable asynchronous probing globally if the knob is set.
> 
> * Identify cases which can't be asynchronous and make them
>   synchronous.  e.g. keep who's doing request_module() and avoid
>   asynchronous probing if current is probing one of those.

What's wrong with just fixing systemd?  Arbitrary timeouts in init
scripts for system bring up are plain wrong ... I thought we had this
sorted out ten years ago when we were first having the arguments about
how long to wait for root; I'm surprised it's coming back again.

If we want to sort out some sync/async mechanism for probing devices, as
an agreement between the init systems and the kernel, that's fine, but
its a to-be negotiated enhancement.  For the current bug fix, just fix
the component that broke ... which would be systemd.

James
