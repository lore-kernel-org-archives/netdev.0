From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] nftables: use list_for_each_entry_safe_reverse to
 traversal commit_list in nf_tables_abort
Date: Sun, 13 Dec 2015 22:47:09 +0100
Message-ID: <20151213214709.GA1827@salvia>
References: <15bcb964221e1a9498e901417d020609cd5aac65.1449485287.git.lucien.xin@gmail.com>
 <20151209140330.GA1695@salvia>
 <CADvbK_dmqu4aFhQa2FVu=_RAVrSZ6qSixfGN9EM2dZ20CeQqUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, davem <davem@davemloft.net>,
	fw@strlen.de
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48244 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750996AbbLMVrR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 16:47:17 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id ED7861324C2
	for <netdev@vger.kernel.org>; Sun, 13 Dec 2015 22:47:16 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id E032EDA807
	for <netdev@vger.kernel.org>; Sun, 13 Dec 2015 22:47:16 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 15DE2DA732
	for <netdev@vger.kernel.org>; Sun, 13 Dec 2015 22:47:15 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <CADvbK_dmqu4aFhQa2FVu=_RAVrSZ6qSixfGN9EM2dZ20CeQqUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 10, 2015 at 12:24:21AM +0800, Xin Long wrote:
> On Wed, Dec 9, 2015 at 10:03 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > On Mon, Dec 07, 2015 at 06:48:07PM +0800, Xin Long wrote:
[...]
> >> the right order of rollback should be:
> >>   'del tab trans' -> 'del set trans' -> 'add set trans'.
> >> which is opposite with commit_list order.
> >>
> >> so fix it by rolling back commits with reverse order in nf_tables_abort.
> >
> >
> > You're reporting a kernel panic.
> >
> > Could you please provide a sequence of commands to reproduce it with
> > the existing code?
> >
> > Thanks.
> 
> the reproduce is a kind of long, do i need to repost this patch with
> the reproduce?

No need to resend.

Yes, we need this reverse iteration there to handle the 'delete table'
command in the batch. This problem happens since we have
nft_flush_table().

Other callsites are artificially restriction deletion of inactive
objects but that should be removed as we already discuss on the
mailing list.

So I'm applying this, thanks.
