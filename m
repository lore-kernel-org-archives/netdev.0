From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] Do not listen if rtnl_send() fails in ip link
 iplink_have_newlink() test
Date: Fri, 3 Jan 2014 12:36:05 -0800
Message-ID: <20140103123605.07468944@nehalam.linuxnetplumber.net>
References: <20131211105749.1ee87844@nehalam.linuxnetplumber.net>
	<1386832705-3101-1-git-send-email-ppisar@redhat.com>
	<20131220082107.0467d57c@nehalam.linuxnetplumber.net>
	<20140102074257.GA1637@dhcp-0-146.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Petr Pisar <ppisar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:42295 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753621AbaACUgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 15:36:08 -0500
Received: by mail-pb0-f45.google.com with SMTP id rp16so16132750pbb.32
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 12:36:08 -0800 (PST)
In-Reply-To: <20140102074257.GA1637@dhcp-0-146.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2 Jan 2014 08:42:57 +0100
Petr Pisar <ppisar@redhat.com> wrote:

> On Fri, Dec 20, 2013 at 08:21:07AM -0800, Stephen Hemminger wrote:
> > I took your idea and enhanced it to all of iproute2 by doing the following:
> > 
> > From c4b6330a3a033bd9c9b0664c5f844493137ae599 Mon Sep 17 00:00:00 2001
> > From: Stephen Hemminger <stephen@networkplumber.org>
> > Date: Fri, 20 Dec 2013 08:15:02 -0800
> > Subject: [PATCH] check return value of rtnl_send and related functions
> > MIME-Version: 1.0
> > Content-Type: text/plain; charset=UTF-8
> > Content-Transfer-Encoding: 8bit
> > 
> > Use warn_unused_result to enforce checking return value of rtnl_send,
> > and fix where the errors are.
> > 
> [...]
> > diff --git a/ip/iplink.c b/ip/iplink.c
> > index 58b6c20..e0c14e6 100644
> > --- a/ip/iplink.c
> > +++ b/ip/iplink.c
> > @@ -178,7 +178,10 @@ static int iplink_have_newlink(void)
> >  		req.n.nlmsg_type = RTM_NEWLINK;
> >  		req.i.ifi_family = AF_UNSPEC;
> >  
> > -		rtnl_send(&rth, &req.n, req.n.nlmsg_len);
> > +		if (rtnl_send(&rth, &req.n, req.n.nlmsg_len) < 0) {
> > +			perror("request send failed");
> > +			exit(1);
> > +		}
> >  		rtnl_listen(&rth, accept_msg, NULL);
> >  	}
> >  	return have_rtnl_newlink;
> 
> This one exits instead of falling back to IOCTL. iplink_have_newlink() is
> called even from iplink_usage(). This even prevents from printing usage.
> 
> I think failure in this very place should be treated as I suggested.
> 
> -- Petr

The code gets used in multiple paths, some should fail and others have
fallback. I will fix the cases where fallback is possible.
