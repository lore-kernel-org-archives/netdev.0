From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: How do I receive vlan tags on an AF_PACKET socket in 3.4 kernel?
Date: Wed, 31 Jul 2013 08:09:30 -0700
Message-ID: <1375283370.10515.100.camel@edumazet-glaptop>
References: <CAMJ=MEe4cvp7-fwbCnq7SLM=44Zy8Jrz35FwRoWG-ytahdPRQA@mail.gmail.com>
	 <1375193392.10515.28.camel@edumazet-glaptop>
	 <CAMJ=MEdfn2uPHbNQZ1LOytOqwFTbAyV1ZtxOW8NomLCZJq+caQ@mail.gmail.com>
	 <1375280187.10515.92.camel@edumazet-glaptop>
	 <CAMJ=MEeLRQTROpj4LBJ2b--dqyxBUKPcW7F=q9qdqxm_4kHL7g@mail.gmail.com>
	 <51F9226F.30202@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ronny Meeus <ronny.meeus@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:57973 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756442Ab3GaPJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 11:09:33 -0400
Received: by mail-pd0-f176.google.com with SMTP id q10so855877pdj.35
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 08:09:33 -0700 (PDT)
In-Reply-To: <51F9226F.30202@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-31 at 16:42 +0200, Daniel Borkmann wrote:

> You can use bpfc (git://github.com/borkmann/netsniff-ng.git), it also has
> an extensive man page. That should probably do it:
> 
> $ cat foo
> ld vlant
> jneq #4094, drop
> ret #-1
> drop: ret #0
> 
> $ bpfc foo
> { 0x20, 0, 0, 0xfffff02c },
> { 0x15, 0, 1, 0x00000ffe },
> { 0x6, 0, 0, 0xffffffff },
> { 0x6, 0, 0, 0x00000000 },

Thanks Daniel.

If the load of this BPF fails (because its an old kernel), then load
your old filter.
