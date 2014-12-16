From: Dominic Hamon <dhamon@twitter.com>
Subject: Re: [PATCH net-next 2/3] Implementation of RFC 4898 Extended TCP
 Statistics (Web10G)
Date: Tue, 16 Dec 2014 14:09:46 -0800
Message-ID: <20141216220946.GA19603@k9>
References: <54908FAD.5060500@psc.edu>
 <20141216.150354.64901094367530710.davem@davemloft.net>
 <54909278.6090806@psc.edu>
 <20141216.151823.2276708539799601894.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:45470 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbaLPWJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 17:09:50 -0500
Received: by mail-pa0-f53.google.com with SMTP id kq14so14913929pab.12
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 14:09:50 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141216.151823.2276708539799601894.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 16, 2014 at 03:18:23PM -0500, David Miller wrote:
> From: rapier <rapier@psc.edu>
> Date: Tue, 16 Dec 2014 15:13:44 -0500
> 
> > On 12/16/14, 3:03 PM, David Miller wrote:
> > 
> >> You shouldn't need to export any symbols.
> > 
> > As a point of clarification - is it acceptable to export symbols for
> > use with in tree modules such as tcp_htcp? We are more than willing to
> > do the work required to bring this in line with best practices.
> 
> I'm saying for data and TCP statistics collection, you shouldn't need
> to add any new symbol exports.
> 
> Keep this in the main kernel, nothing external should be needed.
> 
> Extending tcp_info or similar is the only reasonable way to implement
> this stuff.

There are two aspects of the tcp_estats approach that I think are worth
considering separately:
  - the breadth of instrumentation
  - the access method through kernel module/netlink

I don't see any reason why we can't take the instrumentation parts of
these patches and plumb them in to tcp_info.

I would prefer if we can retain the nested structures and the sysctl
that controls the set of instruments collected as I think this key
feature gives plenty of flexibility to system operators in terms of an
overhead/instrumentation trade-off, however I recognise this complicates
how the socket option is returned, and how ss might report the metrics.

--
Dominic Hamon

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
