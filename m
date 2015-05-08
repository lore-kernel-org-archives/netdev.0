From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v5 2/2] pktgen: introduce xmit_mode '<start_xmit|netif_receive>'
Date: Fri, 08 May 2015 09:50:05 -0700
Message-ID: <554CE93D.3090200@plumgrid.com>
References: <20150507143329.8534.49710.stgit@ivy>	 <20150507143500.8534.4435.stgit@ivy> <554B9293.2070702@plumgrid.com>	 <554B9CDE.1050703@iogearbox.net> <20150508173900.3fcf78de@redhat.com> <1431100621.22756.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:38754 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753689AbbEHQuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 12:50:04 -0400
Received: by igbhj9 with SMTP id hj9so26279149igb.1
        for <netdev@vger.kernel.org>; Fri, 08 May 2015 09:50:04 -0700 (PDT)
In-Reply-To: <1431100621.22756.13.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/8/15 8:57 AM, Eric Dumazet wrote:
>
> I guess an ingress action can do better, by stealing the packet before
> hitting this point.

unfortunately not yet :(
We have spin_lock(&gact->tcf_lock); in tcf_gact,
so simple 'action drop' doesn't scale.
Shouldn't be hard to fix though.
