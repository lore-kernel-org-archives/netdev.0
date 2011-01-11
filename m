From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH V8 02/13] ntp: add ADJ_SETOFFSET mode bit
Date: Tue, 11 Jan 2011 12:09:48 +0100
Message-ID: <20110111110948.GA5279@riccoc20.at.omicron.at>
References: <cover.1293820862.git.richard.cochran@omicron.at>
 <fe2bec763bec155381d62721aa9da84aeca2785c.1293820862.git.richard.cochran@omicron.at>
 <AANLkTini2WdT-1v4k9V3JOZYDkA59P+SyscTe8-fK2Wk@mail.gmail.com>
 <20110108175028.GA22308@riccoc20.at.omicron.at>
 <AANLkTikigXGSACF6R6kfNHyKZ7GFWrUrCMxygvL3fUC6@mail.gmail.com>
 <20110110071759.GA4864@riccoc20.at.omicron.at>
 <AANLkTimS0-ih=WZ_GvPi9NFjbYMT4OctWV943ri4GuTD@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>
To: "Kuwahara,T." <6vvetjsrt26xsrzlh1z0zn4d2grdah@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTimS0-ih=WZ_GvPi9NFjbYMT4OctWV943ri4GuTD@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 11, 2011 at 05:47:13AM +0900, Kuwahara,T. wrote:
> On Mon, Jan 10, 2011 at 4:17 PM, Richard Cochran
> <richardcochran@gmail.com> wrote:
> > the PTP Hardware Clocks for which this whole patch
> > set was created in the first place will keep their time as TAI.
> 
> Are you sure of that?

Yes.

> I don't have the standard handy (it's non-free, right?) but it seems
> that the Annex B states differently.

IEEE Std 1588-2008, Page 41:

        The timescale PTP: In normal operation, the epoch is the PTP
        epoch and the timescale is continuous; see 7.2.4. The unit of
        measure of time is the SI second as realized on the rotating
        geoid.

IEEE Std 1588-2008, Page 42:

        The PTP epoch is 1 January 1970 00:00:00 TAI, which is 31
        December 1969 23:59:51.999918 UTC.

The standard does permit using some other, arbitrary timescale, "set
by an administrative procedure." But no other timescales are
standardized by 1588.

> But that's not the point anyway.  My concern is that your patch not
> only adds the useless (and broken) feature to the existing syscall
> but also makes a permanent change to the public interface for your
> own use.

It is neither useless or broken. Using the new interface, you can
estimate offset and frequency for a few seconds and jump directly into
a closely synchronized state (like within 100 nanoseconds) relative to
another clock on the network. That is pretty useful.

Your issue with leap seconds is really a non-issue. The time value of
the ADJ_SETOFFSET mode is a time interval, *not* an absolute time.

>  That's what I'm against.  So if you stop touching the struct timex,
> I won't complain anymore.

I have no love for the timex interface. However, I used it for the new
syscall because Arnd Bergmann and John Stultz specifically asked for
it. Also, several other people have reviewed the new call without
objecting to the new mode.

Richard
