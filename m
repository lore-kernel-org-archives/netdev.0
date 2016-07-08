From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] net: Fragment large datagrams even when IP_HDRINCL is set.
Date: Sat, 9 Jul 2016 02:21:58 +0300
Message-ID: <CAMrnHh4_yU586bGV9hG0pcbnwPkdNDqrimmipkXam=fOzh3nEg@mail.gmail.com>
References: <20160608.102558.903056863834035706.davem@davemloft.net>
 <BN3PR0201MB10599C7780CBC6EB4BC2894DF9550@BN3PR0201MB1059.namprd02.prod.outlook.com>
 <alpine.LFD.2.20.1607081340430.26593@stoner.jakma.org> <20160708.184129.1545084362199727100.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:35171 "EHLO
	mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518AbcGHXWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 19:22:00 -0400
Received: by mail-it0-f52.google.com with SMTP id u186so20957616ita.0
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 16:21:59 -0700 (PDT)
In-Reply-To: <20160708.184129.1545084362199727100.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

I can tell why it has not been done initially.

Main problem was in IP options, which can be present in raw packet.
They have to be properly fragmented, some options are to be deleted
on fragments. Not that it is too complicated, it is just boring and ugly
and inconsistent with IP_HDRINCL logic.

So, it was done in logically consistent way: did you order IP_HDRINCL?
Please, then deal with fragments yourself.

Alexey
