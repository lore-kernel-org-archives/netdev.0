From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [PATCH v2 2/4] driver core: enable drivers to use deferred probe
 from init
Date: Mon, 28 Jul 2014 12:04:50 -0700
Message-ID: <CAB=NE6VebcR7=UA1n0wNVLr5FFukzq6aW5CkeB3nf5FixV=3cA@mail.gmail.com>
References: <1406572110-26823-1-git-send-email-mcgrof@do-not-panic.com>
 <1406572110-26823-3-git-send-email-mcgrof@do-not-panic.com> <20140728185538.GB17609@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Takashi Iwai <tiwai@suse.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	MPT-FusionLinux.pdl@avagotech.com,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Greg KH <gregkh@linuxfoundation.org>,
	Santosh Rastapur <santosh@chelsio.com>,
	Hariprasad S <hariprasad@chelsio.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20140728185538.GB17609@kroah.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 28, 2014 at 11:55 AM, Greg KH <gregkh@linuxfoundation.org> wrote:
> So, what drivers are having problems in their init sequence, and why
> aren't they using async firmware loading?

Fixing drivers is one thing, fixing drivers *now* because *now*
drivers are failing due to a regression is another thing and that's
what we have now so lets just be clear on that. The 30 second rule is
a major driver requirement change and it should not be taken slightly,
all of a sudden this is a new requirement but you won't know that
unless you're reading these threads or hit an issue. That's an issue
in itself.

The cxgb4: driver is an example where although I did propose patches
to use asynch firmware loading the entire registration of the
netdevice would need to be changed as well in order to get this right.
In short we have to scramble now to first identify drivers that have
long init sequences and then fix. There's an assumption that we can
easily fix drivers, this can take time. This series, although does
take advantage of a kernel interface for other uses, lets us identify
these drivers on the kernel ring buffer, so we can go and address
fixing them with time.

 Luis
