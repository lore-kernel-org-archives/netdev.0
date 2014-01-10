From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] net: xfrm6: silence sparse warning
Date: Thu, 9 Jan 2014 21:30:22 -0800
Message-ID: <20140109213022.7e6f8921@nehalam.linuxnetplumber.net>
References: <1389149801-29011-1-git-send-email-ying.xue@windriver.com>
	<20140107.224357.1577838150943921013.davem@davemloft.net>
	<52CCE83D.5080909@windriver.com>
	<20140108.005656.1582987448512057112.davem@davemloft.net>
	<20140109150451.30b57b2b@nehalam.linuxnetplumber.net>
	<1389322386.2728.66.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <ying.xue@windriver.com>,
	<steffen.klassert@secunet.com>, <dborkman@redhat.com>,
	<netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:37576 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbaAJFa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 00:30:26 -0500
Received: by mail-pd0-f177.google.com with SMTP id q10so4099046pdj.22
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 21:30:25 -0800 (PST)
In-Reply-To: <1389322386.2728.66.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Jan 2014 02:53:06 +0000
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Thu, 2014-01-09 at 15:04 -0800, Stephen Hemminger wrote:
> > On Wed, 08 Jan 2014 00:56:56 -0500 (EST)
> > David Miller <davem@davemloft.net> wrote:
> > 
> > > From: Ying Xue <ying.xue@windriver.com>
> > > Date: Wed, 8 Jan 2014 13:55:09 +0800
> > > 
> > > > 3. Just drop the patch
> > > 
> > > This is the only suitable thing to do.
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > There was some patches floating around to eliminate uses of variable
> > length array in the kernel since they aren't supported by CLANG.
> 
> I think you're mixing up two different things there.  VLAs are part of
> C99 so I'm quite sure Clang supports them (in general).  But they seem
> to be deprecated in the kernel anyway, maybe because they make it easy
> to introduce a stack overflow.
> 
> Ben.
> 

Reading up on this, the problem in CLANG is VLA in Structs;
as in:
struct foo {
  char a[n];
  int b;
};
