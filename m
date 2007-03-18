From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: [PATCH 1/1] [SK_BUFF]: Don't apply the offset of two allocations to the layer headers
Date: Sun, 18 Mar 2007 00:23:05 -0300
Message-ID: <39e6f6c70703172023g1fdf736et21be456106983f80@mail.gmail.com>
References: <20070318031224.GA17811@ghostprotocols.net>
	 <39e6f6c70703172017g1b86198bw1c586f985dd508a6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.234]:58141 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932096AbXCRDXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2007 23:23:06 -0400
Received: by wr-out-0506.google.com with SMTP id 41so1007339wry
        for <netdev@vger.kernel.org>; Sat, 17 Mar 2007 20:23:05 -0700 (PDT)
In-Reply-To: <39e6f6c70703172017g1b86198bw1c586f985dd508a6@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/18/07, Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
> On 3/18/07, Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
> >
> > Hi David,
> >
> >         Here is the bugger, it wasn't because {transport,network,mac}_header
> > is unsigned after all :-)
> >
> >         Please consider pulling from the usual place:
> >
> > master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.22
> >
> >         Please lemme know how longer it takes to crash your workstation, I hope
> > not before next century 8-)
> >
> > - Arnaldo
> >
> > ---
> > In pskb_expand_head and copy_skb_header (used in p?skb_copy(expand)?) the
> > difference of two allocations were being applied to
> > ->(transport|network|mac)_header, when this is not only not needed but causes
> > problems, as those headers are now just offsets from ->head.
> >
> > This fixes the problem with xfrm (skb_copy_checksum was the first place this
>
> Argh, skb_checksum_help! lemme fix this comment before its too late...

Done!

- Arnaldo
