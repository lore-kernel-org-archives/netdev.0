From: Ming Chen <v.mingchen@gmail.com>
Subject: Re: [BUG?] ixgbe: only num_online_cpus() of the tx queues are enabled
Date: Sun, 9 Mar 2014 01:47:27 -0500
Message-ID: <CAG+wggY24+mc=8bCyr3fB+H7DJNfjANQuqbuDRcdUd9=+ip-Ew@mail.gmail.com>
References: <CAG+wggZOQ_VyAiLBuUUfW13=OqUun3g1vnYj5SEuWN+3hHreLg@mail.gmail.com>
	<1394292461.20149.55.camel@edumazet-glaptop2.roam.corp.google.com>
	<1394294883.20149.70.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAG+wggbNpUqL12EAWdXxxxX6mGPj0+1HktDKJeeSxum6emBY_g@mail.gmail.com>
	<1394336258.20149.80.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Erez Zadok <ezk@fsl.cs.sunysb.edu>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Geoff Kuenning <geoff@cs.hmc.edu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:56835 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327AbaCIGr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 01:47:27 -0500
Received: by mail-ig0-f180.google.com with SMTP id hl1so5650201igb.1
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2014 22:47:27 -0800 (PST)
In-Reply-To: <1394336258.20149.80.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 8, 2014 at 10:37 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> The feedback loop you mention should be solved by the patch I sent
> today : TCP Small queue make sure that you have no more than 2 packets
> per flow on qdisc / TX queues. So on 'fast' flow cannot have 90% of the
> packets in the qdisc. cwnd is maintained to very small values, assuming
> receiver is behaving normally.
>

Thanks for the patch. I forgot to mention that excessively big cwnd
(or bufferbloat) does play a part in Hash-Cast. We found that using
TCP Vegas does not show unfairness even in the presence of hash
collision among TCP flows. Comparing Vegas and Cubic, we found that
Vegas has a much smaller cwnd.

Best,
Ming
