From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Sun, 31 Jan 2016 16:04:54 -0800
Message-ID: <1454285094.7627.149.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160129180651.GA17127@oracle.com>
	 <1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1454093642.7627.57.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S34+od6o69rHQzotJFXf7kziEuQUj=xH5VUWw+YpH4FjNg@mail.gmail.com>
	 <20160129210900.GD17127@oracle.com>
	 <CALx6S35V47scFFQab7ZsQyh6CktS17w4hSKZSVAnOB0Ppa7brg@mail.gmail.com>
	 <20160129230424.GG17127@oracle.com>
	 <CALx6S34KtC4kkjzchY5Xs4QapD7FMqxShwEDST0Q_bZgDRicmQ@mail.gmail.com>
	 <20160129235800.GH17127@oracle.com>
	 <CALx6S37KgEPorPp4T4gh8xatsPUTOe=wuhG4fzqx8U35a9O3KA@mail.gmail.com>
	 <1454120138.7627.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S37+xhG-CYDUYqzXcS3FBW+Ta_kjQv6CgYKA2XdQLpHsfQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Michael Dalton <mwdalton@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34991 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933220AbcBAAE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2016 19:04:56 -0500
Received: by mail-pa0-f43.google.com with SMTP id ho8so71492782pac.2
        for <netdev@vger.kernel.org>; Sun, 31 Jan 2016 16:04:56 -0800 (PST)
In-Reply-To: <CALx6S37+xhG-CYDUYqzXcS3FBW+Ta_kjQv6CgYKA2XdQLpHsfQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-01-31 at 14:13 -0800, Tom Herbert wrote:

> Neither is GRE enabled by default in Linux and it is not a typical
> case. So that patch is an optimization for a very narrow use case that
> impacts the core data path for everyone. Please at least consider
> making it configurable.

No idea why it should be configurable, by adding yet another
conditional.

Pulling all headers at once is faster than pulling in GRO slow path, or
if GRO is disabled in pskb_may_pull() slow path.

It seems we need to fix flow dissector anyway.

Note: This path is only taken in non native traffic, in case you missed
this.

Regular IP+TCP or IP+UDP does not use it.
