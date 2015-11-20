From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf: add show_fdinfo handler for maps
Date: Thu, 19 Nov 2015 19:30:41 -0800
Message-ID: <20151120033040.GA13060@ast-mbp.thefacebook.com>
References: <b3f1dd7e21d72dc47beac222d655640ee584c5cd.1447930253.git.daniel@iogearbox.net>
 <1447957164.2292053.444566657.27F336C7@webmail.messagingengine.com>
 <20151119183240.GA5993@ast-mbp.thefacebook.com>
 <1447963950.3032383.444676081.5CE47461@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33610 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758427AbbKTDap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 22:30:45 -0500
Received: by pabfh17 with SMTP id fh17so105240974pab.0
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 19:30:44 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1447963950.3032383.444676081.5CE47461@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 19, 2015 at 09:12:30PM +0100, Hannes Frederic Sowa wrote:
> On Thu, Nov 19, 2015, at 19:32, Alexei Starovoitov wrote:
> > On Thu, Nov 19, 2015 at 07:19:24PM +0100, Hannes Frederic Sowa wrote:
> > > On Thu, Nov 19, 2015, at 11:56, Daniel Borkmann wrote:
> > > > Add a handler for show_fdinfo() to be used by the anon-inodes
> > > > backend for eBPF maps, and dump the map specification there. Not
> > > > only useful for admins, but also it provides a minimal way to
> > > > compare specs from ELF vs pinned object.
> > > > 
> > > > Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> > > 
> > > Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > > 
> > > Does it make sense to include bpf_htab->count in case of a hashmap?
> > 
> > no. user space should not rely on such things. It can only be misused.
> 
> Sorry, I don't get it. How can it be misused? As an admin it would
> certainly be interesting to know the pressure on the map? Do you expect
> kmsg messages from the eBPF program?

If user space can be see both 'count' and 'max_entries', it can be very
tempting to start assuming 'full' and 'empty' state of the map which will
lead to race conditions and bad design.
bpf programs and maps are inherently multi-thread and concurrent.
If userapp wants to do the counting of elements it needs to do so on its own
and shoot itself in the foot eventually.
For the same reason I don't want to see BPF_MAP_GET_COUNT command.
