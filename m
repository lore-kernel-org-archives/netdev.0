From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 8/8]  prism54/islpci_dev: replace schedule_timeout() with msleep()
Date: Thu, 2 Sep 2004 18:27:19 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040902182719.GD1944@us.ibm.com>
References: <200409021952.18280.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: Margit Schubert-While <margitsw@t-online.de>
Content-Disposition: inline
In-Reply-To: <200409021952.18280.margitsw@t-online.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Sep 02, 2004 at 07:52:18PM +0200, Margit Schubert-While wrote:
> On Thu, 02 Sep 2004, Nishanth scribeth:
> > Keep in mind that msleep_interruptible() is also
> > (hopefully) being pushed to the kernel soon
> 
> I think you need this for your current patch set ;-)
> eg. In e100, where you replace an interruptible timeout:
> > @@ -2020,8 +2016,7 @@
> 
> I don't think that's correct.

The reasoning for me behind changing some of the TASK_INTERRUPTIBLE'd
schedule_timeout()s to msleep()s was that LDD somewhat incorrectly
advised device driver authors to use an INTERRUPTIBLE timeout for longer
delays, when, in fact, they should probably use an UNINTERRUPTIBLE one.
Only if signals are explicitly expected to occur is INTERRUPTIBLE
necessary (in general). [By long delays, I mean those measurable in
msecs]

I am not an expert on the E100, so perhaps this was an error on my part.
But this is also why I have a header on my patch submission regarding
exactly this issue.

If someone could verify (none of the maintainers I sent the original
patch to did not reply with any problems for this patch) that there is
or is not an issue, I'd appreciate it.

-Nish
