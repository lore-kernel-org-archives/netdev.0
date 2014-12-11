From: vadim4j@gmail.com
Subject: Re: [PATCH iproute2] ip: Simplify executing ip cmd within namespace
Date: Thu, 11 Dec 2014 18:33:35 +0200
Message-ID: <20141211163335.GA27913@angus-think.wlc.globallogic.com>
References: <1418252195-2612-1-git-send-email-vadim4j@gmail.com>
 <20141211170928.62c8e637@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:41734 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbaLKQn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 11:43:28 -0500
Received: by mail-lb0-f179.google.com with SMTP id z11so4417559lbi.38
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 08:43:26 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141211170928.62c8e637@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 11, 2014 at 05:09:28PM +0100, Jiri Benc wrote:
> On Thu, 11 Dec 2014 00:56:35 +0200, Vadim Kochan wrote:
> > From: Vadim Kochan <vadim4j@gmail.com>
> > 
> > Added new '-ns' option to simplify executing following cmd:
> > 
> >     ip netns exec NETNS ip OPTIONS COMMAND OBJECT
> > 
> >     to
> > 
> >     ip -ns NETNS OPTIONS COMMAND OBJECT
> > 
> > e.g.:
> > 
> >     ip -ns vnet0 link add br0 type bridge
> 
> This is great! It's a thing that has been bothering me for long time
> but never got high enough on my todo list. Thanks for working on this.
> 
> However,
> 
> > --- a/ip/ip.c
> > +++ b/ip/ip.c
> > @@ -262,6 +262,12 @@ int main(int argc, char **argv)
> >  			rcvbuf = size;
> >  		} else if (matches(opt, "-help") == 0) {
> >  			usage();
> > +		} else if (matches(opt, "-ns") == 0) {
> > +			argc--;
> > +			argv++;
> > +			argv[0] = argv[1];
> > +			argv[1] = basename;
> > +			return netns_exec(argc, argv);
> 
> I very much dislike this. There's no reason to exec another ip binary.
> The main reason I wanted the -n (or whatever) option was to speed up
> execution of test scripts in environments with hundreds of interfaces
> in different net namespaces.
> 
> Please just change to the specified netns and continue with interpreting
> of the rest of the command line, there's absolutely no reason for doing
> the exec.
Yes, I will follow that way.

Thanks,
> 
> Thanks,
> 
>  Jiri
> 
> -- 
> Jiri Benc
