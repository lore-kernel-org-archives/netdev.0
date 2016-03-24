From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Thu, 24 Mar 2016 11:37:48 -0700
Message-ID: <1458844668.12033.22.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20151219070009.GA4634@1wt.eu>
	 <CALx6S35248apbWqtG+g2U99O=4UJqyAG0bJeuxhZWtShrpDF+w@mail.gmail.com>
	 <20151221204127.GC8018@1wt.eu>
	 <CALmu+SwjG0GVocGufTbgX-WJfcsP85SvHB=xtW7qQX3kZwJCxg@mail.gmail.com>
	 <20160324061222.GA6807@1wt.eu>
	 <1458828813.10868.65.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160324142222.GB7237@1wt.eu>
	 <1458830744.10868.72.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160324153053.GA7569@1wt.eu>
	 <1458837191.12033.4.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160324165047.GA7585@1wt.eu>
	 <1458838897.12033.10.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CALx6S36Ej1es8qFi2Q3=199f+rmG=Za02N5ZBWT5DCRqrBEWvQ@mail.gmail.com>
	 <56F42A00.7050002@iogearbox.net>
	 <CALmu+SxF5dDEBwpk-R=V5DGZBed1rvjYGEJ+cU8ZhyAdLWshug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Tom Herbert <tom@herbertland.com>, Willy Tarreau <w@1wt.eu>,
	Craig Gallek <cgallek@google.com>,
	Josh Snyder <josh@code406.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tolga Ceylan <tolga.ceylan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34089 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250AbcCXShu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 14:37:50 -0400
Received: by mail-pf0-f179.google.com with SMTP id x3so64558624pfb.1
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 11:37:50 -0700 (PDT)
In-Reply-To: <CALmu+SxF5dDEBwpk-R=V5DGZBed1rvjYGEJ+cU8ZhyAdLWshug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-03-24 at 11:20 -0700, Tolga Ceylan wrote:
> On Thu, Mar 24, 2016 at 10:55 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> > On 03/24/2016 06:26 PM, Tom Herbert wrote:
> >>
> >> I completely agree with this, but I wonder if we now need a repository
> >> of useful BPF modules. So in the case of implementing functionality
> >> like in SO_REUSEPORT_LISTEN_OFF that might just become a common BPF
> >> program we could direct people to use.
> >
> >
> > Good point. There's tools/testing/selftests/net/ containing already
> > reuseport
> > BPF example, maybe it could be extended.
> 
> I would appreciate a conceptual description on how this would work
> especially for a common scenario
> as described by Willy. My initial impression was that a coordinator
> (master) process takes this
> responsibility to adjust BPF filters as children come and go.
> 
> Two popular software has similar use cases: nginx and haproxy. Another
> concern is with the
> introduction of BPF itself, should we expect a performance drop in
> these applications?

Just to make it clear : 

BPF allows proper siloing if you have multi queue NIC, instead of a
random hashing that was reducing performance.

BPF on SO_REUSEPORT can reduce false sharing between cpus and increase
NUMA locality.

BPF allows us to use whatever number of silos, without having to scan
the whole socket list for every incoming packet.

Huge gain really.
