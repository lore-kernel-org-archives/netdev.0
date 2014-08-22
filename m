From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP output handling bug ?
Date: Fri, 22 Aug 2014 06:56:30 -0700
Message-ID: <1408715790.5604.13.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140821190208.208e0de1@www.etchedpixels.co.uk>
	 <20140821172445.7c1ba422@uryu.home.lan> <20140822021341.GB14353@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:62143 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932112AbaHVN4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 09:56:32 -0400
Received: by mail-pd0-f180.google.com with SMTP id v10so15975808pde.11
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 06:56:32 -0700 (PDT)
In-Reply-To: <20140822021341.GB14353@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-08-21 at 22:13 -0400, Dave Jones wrote:
> On Thu, Aug 21, 2014 at 05:24:45PM -0700, Stephen Hemminger wrote:
>  > On Thu, 21 Aug 2014 19:02:08 +0100
>  > Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
>  > 
>  > > 
>  > > tcp_send_syn_data:
>  > > 
>  > >         TCP_SKB_CB(data)->tcp_flags &= ~TCPHDR_SYN;
>  > >         TCP_SKB_CB(data)->tcp_flags = (TCPHDR_ACK|TCPHDR_PSH);
>  > > 
>  > > the reporter has a point 8)
>  > > 
>  > > https://bugzilla.kernel.org/show_bug.cgi?id=82101
>  > 
>  > I wonder if covertity or smatch could be smart enough to catch this kind of bug?
> 
> For coverity: it should be, but isn't :)
> I've pointed them at the bugzilla, maybe they can add a check in a
> future update.
> 
> I bet this isn't the only instance of a bug like this left in the tree.
> We've definitely had similar cases before.
> 
> 	Dave


There is no bug here as a matter of fact.

You can simply remove the first line, as it is useless.


-	TCP_SKB_CB(data)->tcp_flags &= ~TCPHDR_SYN;


At the end of the day, data segment has ACK and PSH flags only.
