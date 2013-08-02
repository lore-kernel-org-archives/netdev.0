From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Bug 60669] Kernel panic when using negative priority for HTB
 class
Date: Thu, 1 Aug 2013 22:31:15 -0700
Message-ID: <20130801223115.59a1ac76@nehalam.linuxnetplumber.net>
References: <20130801211231.1b25c3be@nehalam.linuxnetplumber.net>
 <ktfdq8$882$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:42921 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754694Ab3HBFcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 01:32:19 -0400
Received: by mail-pa0-f68.google.com with SMTP id kl13so150150pab.3
        for <netdev@vger.kernel.org>; Thu, 01 Aug 2013 22:32:18 -0700 (PDT)
In-Reply-To: <ktfdq8$882$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2 Aug 2013 04:50:16 +0000 (UTC)
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> On Fri, 02 Aug 2013 at 04:12 GMT, Stephen Hemminger <stephen@networkplumber.org> wrote:
> >
> > --- Comment #2 from _Vi <vi0oss@gmail.com> ---
> > Reproducible on 3.11.0-rc3
> >
> > Looks like negative priority value is essential for the kernel panic.
> >
> 
> There is a check for prio:
> 
>                 if ((cl->prio = hopt->prio) >= TC_HTB_NUMPRIO)
> 		                        cl->prio = TC_HTB_NUMPRIO - 1;
> 					

This maybe related to or old bugs, 64 bit with current
iproute2 the error is caught at the command level.

The issue is that hopt->prio is u32 but cl->prio is int.

Example:
int main()
{
	int x = -1;
	uint32_t prio = x;
	int cl;

	if ((cl = prio) >= TC_HTB_NUMPRIO)
		cl = TC_HTB_NUMPRIO - 1;

	printf("%d %u %d\n", x, prio, cl);
	return 0;
}
-1 4294967295 -1

Signed/unsigned conversions can bite.
