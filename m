From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: cls_cgroup: Store classid in struct sock
Date: Mon, 24 May 2010 07:09:50 -0400
Message-ID: <20100524110950.GA22216@hmsreliant.think-freely.org>
References: <20100523.234441.66200781.davem@davemloft.net>
 <20100523.235557.165343768.davem@davemloft.net>
 <20100524070743.GA26871@gondor.apana.org.au>
 <20100524.001429.259990428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, eric.dumazet@gmail.com,
	bmb@athenacr.com, tgraf@redhat.com, nhorman@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44658 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755361Ab0EXLKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 07:10:06 -0400
Content-Disposition: inline
In-Reply-To: <20100524.001429.259990428.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 24, 2010 at 12:14:29AM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Mon, 24 May 2010 17:07:43 +1000
> 
> > On Sun, May 23, 2010 at 11:55:57PM -0700, David Miller wrote:
> >>
> >> Probably you only tested the build with cgroups enabled?
> > 
> > Indeed, that does seem to be the problem here.  It turns out
> > that their struct is only declared when CONFIG_CGROUPS is defined,
> > how annoying.
> > 
> > Oh well I guess I'll follow their example :)
> > 
> > cls_cgroup: Store classid in struct sock
> 
> Thanks for fixing this up, applied.
> 


Excuse all my noise from before, Herberts patch works fine.  Apparently the
problem was mine.  QEMU creates several threads during startup, but adding the
processid to a cgroup doesn't cause its child threads to get added
automatically.  Doing this by hand causes this to work.

Thanks
Neil

