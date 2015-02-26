From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 2/2] rhashtable: remove indirection for grow/shrink
 decision functions
Date: Thu, 26 Feb 2015 06:50:36 -0800
Message-ID: <1424962236.5565.156.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAADnVQKV8JSqhTPYBGDJt4KqTesEvtCMnhupiPyZJjvk=tmOwg@mail.gmail.com>
	 <20150226075354.GA30061@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	David Laight <David.Laight@aculab.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35344 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932084AbbBZOui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 09:50:38 -0500
Received: by padfa1 with SMTP id fa1so14510243pad.2
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 06:50:38 -0800 (PST)
In-Reply-To: <20150226075354.GA30061@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-26 at 07:53 +0000, Patrick McHardy wrote:

> My understanding was that Eric was arguing against shrinking in general.
> But assuming we have it, what's the downside of also performing
> shrinking for TCP?

Hash resize is horribly expensive (this is general to all hash
implementations), so once you took the risk to expand the table once,
you do not want to take the risk another time. You are lucky if host was
not already taken out of the server pool.

Fact that cond_resched() is not yet used anywhere in lib/rhashtable.c
reveals part of the problem we have here.

(I'll submit patches for that)
