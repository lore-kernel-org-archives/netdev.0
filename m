From: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Subject: Re: Silicom bypass driver promote from staging
Date: Mon, 29 Sep 2014 13:07:15 -0400
Message-ID: <20140929170715.GA21180@kroah.com>
References: <3BFAEADE799AF145974162DF00E013AF018F80FFCF@exchange2010.silicom.local>
 <20140805150957.GC27303@kroah.com>
 <3BFAEADE799AF145974162DF00E013AF018F814DAB@exchange2010.silicom.local>
 <20140807215115.GB19520@electric-eye.fr.zoreil.com>
 <3BFAEADE799AF145974162DF00E013AF018F8C8A9F@exchange2010.silicom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"arnd@arndb.de" <arnd@arndb.de>, Anna Lukin <annal@silicom.co.il>
To: David Hendel <david@silicom.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:38993 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751967AbaI2RIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 13:08:12 -0400
Content-Disposition: inline
In-Reply-To: <3BFAEADE799AF145974162DF00E013AF018F8C8A9F@exchange2010.silicom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2014 at 07:18:35AM +0000, David Hendel wrote:
> Hi all,
> Sorry, for the late response, we had to go over all the code and update as requested and then test to verify, so here it is.
> 
> See below with some responses and attached, hope we can move forward with that. getting the bypass driver into the kernel.
> 
> On Thu, 7 Aug 2014 19:56 Stephen Hemminger <stephen@networkplumber.org> wrote:
> >The current driver uses a device specific /proc interface.
> >That API programming model will not likely be acceptable in a standard network driver.
> >Please consider doing something generic with netlink.
> 
> Actually, this is not a network driver, many of the users use this
> interface to  control the bypass/fail-to-wire to control this
> function. We can add netlink api as additional interface,  but  not
> having  proc interface maybe a problem.

I'm not going to accept a proc interface for a network driver, sorry,
please use netlink.  /proc is only for processes for any new
files/functionality.

> On Thu, 7 Aug 2014 23:20 gregkh@linuxfoundation.org wrote:
> >Making your patch an attachment in base64 mode, makes it impossible to 
> >quote to review it :(
> >
> >Anyway, I stopped at the first header file.  The kernel already has BIT definitions, no driver should ever have to redefine these and do it on their own.
> >  That leads me to believe that this code really isn't all that "cleaned up" at all.
> >
> >Should I just look at what is in drivers/staging/silicom/ right now as code to review?  Or have you changed it any by making this patch?
> 
> OK, will do that,
> drivers/staging/silicom/ driver was created from silicom bypass driver released in December 2012. 
> The driver we are providing now is based on this staging driver.
> We updated it to our Latest release (adding support for new adapters, some changes in functionality) and fixed bug (loading the driver from staging led to kernel panic).
> 
> 
> On Fri, 8 Aug 2014 00:51 Francois Romieu <romieu@fr.zoreil.com> wrote:
> >Location is the easy part. Getting things reviewed is a different story.
> >
> >You shouldn't expect reviewers to swallow 300k of code (600k / 2 due to removal). Please split the submitted patch into smaller, self-consistent, logical ones.
> >
> We will include the patches in the following emails inline each will have smaller size, hope this will be as you expect.
> 
> >Notwithstanding Stephen and Jeff's remarks, you should also:
> >- remove the (out-)commented code
> >- reconsider the use of gorilla class macros vs plain functions
> >- stop casting ioremap return into long, then later into void *. It's
> >  void __iomem * and should stay so.
> >- use a consistent locking style and remove BP_SYNC_FLAG
> >- fix the 80 cols limit problem(s) (hardly surprizing after 5 levels of
>  > nested "if")
> >- avoid redefining stuff from include/uapi/linux/mii.h
> > I may be wrong but BPCTLI_MII_CR_POWER_DOWN smells of BMCR_PDOWN and
> >  BPCTLI_PHY_CONTROL, well, MII_BMCR ?
> >- avoid returning with spinlock held (read_reg, wdt_pulse)
> >- start explaining what did change between two submissions
> 
> This is what we changed in updated patch:
> 1. Avoid redefining BIT and MII .
> 2. Fixing returning with spinlock held
> 3. Remove BP_SYNC_FLAG
> 4. Use void __iomem * instead of long long in ioremap return
> 5. Cleanup with checkpatch.pl
> 
> Hope that it is OK now, or at least better.
> 
> Here is the code,
> 
> 
> Bp_ctl patch,
> --------------------------------------------------------------------------------------------------
> Signed-off-by: Anna Lukin <annal@silicom.co.il>
> diff -uprN -X linux-3.17-rc1-vanilla/Documentation/dontdiff linux-3.17-rc1-vanilla/drivers/bypass/Kconfig linux-3.17-rc1/drivers/bypass/Kconfig
> --- linux-3.17-rc1-vanilla/drivers/bypass/Kconfig	1970-01-01 02:00:00.000000000 +0200
> +++ linux-3.17-rc1/drivers/bypass/Kconfig	2014-08-03 13:48:27.000000000 +0300

This is in an odd format, please read Documentation/SubmittingPatches
for the proper format to send a patch in.  There's nothing I can do with
this one, or your other one, sorry :(

greg k-h
