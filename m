From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf: add show_fdinfo handler for maps
Date: Thu, 19 Nov 2015 10:45:07 -0800
Message-ID: <20151119184506.GA6125@ast-mbp.thefacebook.com>
References: <b3f1dd7e21d72dc47beac222d655640ee584c5cd.1447930253.git.daniel@iogearbox.net>
 <1447957164.2292053.444566657.27F336C7@webmail.messagingengine.com>
 <564E169A.6070506@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35986 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934528AbbKSSpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 13:45:12 -0500
Received: by pacdm15 with SMTP id dm15so89013174pac.3
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 10:45:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <564E169A.6070506@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 19, 2015 at 07:36:10PM +0100, Daniel Borkmann wrote:
> On 11/19/2015 07:19 PM, Hannes Frederic Sowa wrote:
> >On Thu, Nov 19, 2015, at 11:56, Daniel Borkmann wrote:
> >>Add a handler for show_fdinfo() to be used by the anon-inodes
> >>backend for eBPF maps, and dump the map specification there. Not
> >>only useful for admins, but also it provides a minimal way to
> >>compare specs from ELF vs pinned object.
> >>
> >>Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> >
> >Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> >
> >Does it make sense to include bpf_htab->count in case of a hashmap?
> 
> It would give a sort-of only volatile view, e.g. like the map's
> refcount. It would be possible to show it, but only as kind of
> informative to an admin, have no strong opinion on it, though.
> 
> I think this goes rather into the direction of better debugging
> interfaces for eBPF, probably makes sense think about it wrt a
> general debugging/introspection framework and better dump it
> there ...

refcnt to userspace?! nack.
I'm strongly against such 'debugging' that can only be misused
if exposed to user space. Regardless whether it's admin or not.
