From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: [PATCH 2/2] posix clocks: introduce a sysfs presence.
Date: Fri, 10 Sep 2010 00:00:08 +0100
Message-ID: <20100910000008.1483fdd7@lxorguk.ukuu.org.uk>
References: <cover.1283504065.git.richard.cochran@omicron.at>
	<84124d2479b8967cac2b35f852fc0fcae6ad9444.1283504065.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <84124d2479b8967cac2b35f852fc0fcae6ad9444.1283504065.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 3 Sep 2010 11:30:13 +0200
Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> This patch adds a 'timesource' class into sysfs. Each registered POSIX
> clock appears by name under /sys/class/timesource. The idea is to
> expose to user space the dynamic mapping between clock devices and
> clock IDs.

This is intrinsically racy so not a good API at all.

By the time I have acquired an id from sysfs it may have been re-issued
or changed.

POSIX habit of enumerating objects not properties of objects is one of
the brain dead aspects of POSIX that we should have nothing to do with.

Also we have existing time sources that don't follow the poxix clock
model - I can open /dev/rtc and I can open the hpet and so on.

I like /sys/class/time* *but* you need to be able to open the sysfs
device and apply operations to it in order for it to work when your closk
can be dynamically created and destroyed and to get a sane Unix API.

To start with try applying permissions to clock sources via the POSIX
API. That is something that will be required for some applications.

I need to be able to open sys/clock/foo/something and get a meaningful
handle. Sure it's quite likely the operations it supports are related to
the POSIX timer ops.

Alan
