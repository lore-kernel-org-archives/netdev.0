From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH dscape] d80211: Switch d80211.h to IEEE80211_ style names
Date: Sat, 5 Aug 2006 19:30:55 +0200
Message-ID: <200608051930.55792.mb@bu3sch.de>
References: <200607270037.22384.flamingice@sourmilk.net> <20060801122142.GB29208@tuxdriver.com> <20060805114650.GC21135@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Christoph Hellwig <hch@infradead.org>,
	Michael Wu <flamingice@sourmilk.net>,
	Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:32180
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1422637AbWHERbi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 13:31:38 -0400
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060805114650.GC21135@infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 05 August 2006 13:46, Christoph Hellwig wrote:
> On Tue, Aug 01, 2006 at 08:21:49AM -0400, John W. Linville wrote:
> > I don't anticipate the d80211 naming conventions to ever make it out
> > of wireless-dev.  By the time we are ready to push that stuff upstream,
> > we will have cleaned-up our messes.
> 
> Yes, absolutely.
> 
> > This does raise the question: Should we start taking patches to
> > wireless-dev that migrate the current (i.e. ieee80211/softmac) stack
> > out of the kernel?  This would include (re-)moving the current stack
> > code, pointing non-migrated drivers (ipw2[12]00, zd1211rw) at the old
> > code, moving drivers out of drivers/net/wireless/d80211 up a level,
> > removing the softmac-based version of the bcm43xx driver, etc.

Yes, I personally would like to see that happen now.

> I think you first need to come up with a way to deal with ipw2[12]00,
> dealing with that kind of devices is priority number one before the
> devicescape stack can go anywhere.  Once that is handled all software
> MAC drivers in wireless-dev should be migrated to the device-scape based
> stack.

Well, I think we all agreed on what to do with ipw at the wireless summit.
As far as I remember all agreed to move the softmac-only drivers to their
own directory. Simply the reverse of what is currently in wireless-dev.
Currently we have d80211 drivers in their own dir.
After that move was done, we port softmac drivers over to d80211
and delete the softmac version once it's stabilized. If no softmac
driver is left, we delete the old ieee80211 subsystem.

> After that we're in the right position to deal with last big step of
> the merge:
> 
>  a) deal with the userspace interface issue.  Either rever to the single
>     network device and eth%d name interface (at least for the non-AP case)
>     so existing userspace won't know about the name underlying stack at
>     all or alternatively go through the painfull design process for a new
>     userspace interface.  I think the first variant will be a lot easier..

Not in the long term, IMHO.

-- 
Greetings Michael.
