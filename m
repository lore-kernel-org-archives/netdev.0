From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] tipc: cleanup function namespace
Date: Wed, 13 Oct 2010 17:32:57 -0700
Message-ID: <20101013173257.127ae6aa@nehalam>
References: <1286929558-2954-5-git-send-email-paul.gortmaker@windriver.com>
	<20101013162652.GF31379@hmsreliant.think-freely.org>
	<4CB5E79B.4060507@windriver.com>
	<20101013.142834.226768662.davem@davemloft.net>
	<20101013162035.0c2e8123@nehalam>
	<4CB64D7C.1080004@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, allan.stephens@windriver.com
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49025 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751589Ab0JNAdA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Oct 2010 20:33:00 -0400
In-Reply-To: <4CB64D7C.1080004@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Oct 2010 20:23:24 -0400
Paul Gortmaker <paul.gortmaker@windriver.com> wrote:

> On 10-10-13 07:20 PM, Stephen Hemminger wrote:
> > Do some cleanups of TIPC based on make namespacecheck
> >    1. Don't export unused symbols
> >    2. Eliminate dead code
> >    3. Make functions and variables local
> >    4. Rename buf_acquire to tipc_buf_acquire since it is used in several files
> > 
> > Compile tested only.
> > This make break out of tree kernel modules that depend on TIPC routines.
> 
> Hi Stephen,
> 
> When I first started looking at TIPC code, I too came to the
> same conclusion as you did and was about to do #1,2,3 -- but
> then I was told that the exported symbols were part of an API
> and might be in use by folks here and there as per this thread:
> 
> http://www.mail-archive.com/netdev@vger.kernel.org/msg30208.html
> 
> I'm generally the 1st one to agree that the kernel should not
> be libc, and that exporting all sorts of functions without a
> clearly defined use case so that one can insert all sorts of
> brewed up modules is *not* the way to go -- and was asking if
> we could phase this API out if nobody was using it:
> 
> http://sourceforge.net/mailarchive/message.php?msg_name=29C1DC0826876849BDD9F1C67ABA294308C1FEB6%40ala-mail09.corp.ad.wrs.com
> 
> ...but apparently there are a couple of API users out there.
> 
> I'd like to better understand their use case(es) and what parts
> of this API they use, but I haven't got that far yet, since
> there are a bunch of other TIPC bugfixes and changes queued on
> sourceforge which need cleaning and integration into mainline.
> 
> I was thinking one idea would be to wrap them in a TIPC specific
> Kconfig (off by default) so that it would at least highlight
> this atypical use case for EXPORT_SYMBOL -- which might help
> bring these users to the surface so we can learn about their
> use cases.  Having it as a Kconfig option would also help in
> giving us something to point our finger at for the feature
> removal file, if indeed we could find a better way for these
> users to get done whatever it is that they are doing.
> 
> In any event, I think your #2 (dead code) and #3 (add static)
> are items considered dead or candidates for static because
> of #1, i.e. tossing the API exports out.
> 
> I've already tossed out the explicitly dead code in #if 0
> blocks -- Dave just merged that today.   But the #4 from your
> list seems to make sense, and we can do that as a standalone
> item of course.
> 
> Thanks,
> Paul.
> 
> > 
> > Signed-off-by: Stephen Hemminger<shemminger@vyatta.com>
> > 

The kernel is does not have or support API's just for out
of tree code. Any code that needs the API should be submitted for
inclusion or risks getting broken at any time!
