From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Wed, 10 Sep 2014 07:52:45 +0900
Message-ID: <20140909225245.GC3154@mtj.dyndns.org>
References: <20140905224047.GC15723@mtj.dyndns.org>
 <CAB=NE6Uz1VD5qpMFSBfQRV8ih9FQcCUhNtWMvD38t5hdDvix4Q@mail.gmail.com>
 <20140909011059.GB11706@mtj.dyndns.org>
 <1410241109.2028.22.camel@jarvis.lan>
 <CAB=NE6WGAMvffGDTkN5x5Cd+YOtD-Cmo3v7_8FmJ5cvCRbFEpw@mail.gmail.com>
 <1410291346.13298.16.camel@jarvis.lan>
 <20140909214240.GA3154@mtj.dyndns.org>
 <1410301562.13298.35.camel@jarvis.lan>
 <20140909224143.GB3154@mtj.dyndns.org>
 <1410302783.13298.50.camel@jarvis.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1410302783.13298.50.camel@jarvis.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, James.

On Tue, Sep 09, 2014 at 03:46:23PM -0700, James Bottomley wrote:
> If you want the return of an individual device probe a log scraper gives
> it to you ... and nothing else does currently.  The advantage of the
> prink in dd.c is that it's standard for everything and can be scanned
> for ... if you take that out, you'll get complaints about the lack of
> standard messages (you'd be surprised at the number of enterprise
> monitoring systems that actually do log scraping).

Why would a log scaper care about which task is printing the messages?
The printk can stay there.  There's nothing wrong with it.  Log
scapers tend to be asynchronous in nature but if a log scraper wants
to operate synchronously for whatever reason, it can simply not turn
on async probing.

> OK, so we just fire and forget in userland ... why bother inventing an
> elaborate new infrastructure in the kernel to do exactly what
> 
> modprobe <mod> &
> 
> would do?

I think the argument there is that the issuer wants to know whether
such operations succeeded or not and wants to report and record the
result and possibly take other actions in response.  We're currently
mixing wait and error reporting for one type of operation with wait
for another.  I'm not saying it's a fatal flaw or anything but it can
get in the way.

Thanks.

-- 
tejun
