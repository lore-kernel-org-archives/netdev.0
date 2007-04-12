From: "SANGTAE HA" <sangtae.ha@gmail.com>
Subject: Re: TCP connection stops after high load.
Date: Wed, 11 Apr 2007 22:44:02 -0400
Message-ID: <649aecc70704111944y5b6ceecenafd97d6252b3d8db@mail.gmail.com>
References: <461D447C.4070408@candelatech.com>
	 <20070411.134804.50594117.davem@davemloft.net>
	 <461D4DD7.7020207@candelatech.com>
	 <20070411.141143.82097512.davem@davemloft.net>
	 <461D5394.9040409@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Ben Greear" <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.224]:32726 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161498AbXDLCoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2007 22:44:03 -0400
Received: by wr-out-0506.google.com with SMTP id 76so328121wra
        for <netdev@vger.kernel.org>; Wed, 11 Apr 2007 19:44:03 -0700 (PDT)
In-Reply-To: <461D5394.9040409@candelatech.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I also noticed this happening with 2.6.18 kernel version, but this was
not severe with linux 2.6.20.3.  So, the short-term solution will be
upgrading to the latest kernel of FC-6.

A long black-out is mostly observed when a lot of packet losses
happened in slow start. You can prevent this by applying a patch
(limited slow start) to your slow start. Did you have same problems
with cubic which employs a less aggressive slow start?  I leave this
debugging for some later version of kernel but you are welcome to
debug this problem.

I recommend you install tcp_probe and recreate the problem. Whenever
you get an ack from the receiver, the probe will print the current
congestion information. Also, you can easily include some other
information you want in that module. You can get some information from
some statistics on /proc/net/tcp and /proc/net/netstat.

See http://netsrv.csc.ncsu.edu/wiki/index.php/Efficiency_of_SACK_processing

Thanks,
Sangtae



On 4/11/07, Ben Greear <greearb@candelatech.com> wrote:
> David Miller wrote:
> > From: Ben Greear <greearb@candelatech.com>
> > Date: Wed, 11 Apr 2007 14:06:31 -0700
> >
> >> Does the CWND == 1 count as solid?  Any idea how/why this would go
> >> to 1 in conjunction with the dup acks?
> >>
> >> For the dup acks, I see nothing *but* dup acks on the wire...going in
> >> both directions interestingly, at greater than 100,000 packets per second.
> >>
> >> I don't mind adding printks...and I've started reading through the code,
> >> but there is a lot of it, and indiscriminate printks will likely just
> >> hide the problem because it will slow down performance so much.
> >
> > If you know that it doesn't take Einstein to figure out that maybe you
> > should add logging when CWND is one and we're sending out an ACK?
>  >
> > This is why I think you're very lazy Ben and I get very agitated with
> > all of your reports, you put zero effort into thinking about how to
> > debug the problem even though you know full well how to do it.
>
> I've spent solid weeks tracking down obscure races.  I'm hoping that
> someone who knows the tcp stack will have some idea of places to look
> based on the reported symptoms so that I don't have to spend another
> solid week chasing this one.  If not, so be it..I'm still working on
> this between sending emails.  For what it's worth, the problem (or something similar)
> is reproducible on a stock FC5 .18-ish kernel as well, running between
> two machines, 2 ports each.
>
> Ben
>
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
