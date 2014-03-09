From: Ming Chen <v.mingchen@gmail.com>
Subject: Re: [BUG?] ixgbe: only num_online_cpus() of the tx queues are enabled
Date: Sat, 8 Mar 2014 19:53:01 -0500
Message-ID: <CAG+wggbNpUqL12EAWdXxxxX6mGPj0+1HktDKJeeSxum6emBY_g@mail.gmail.com>
References: <CAG+wggZOQ_VyAiLBuUUfW13=OqUun3g1vnYj5SEuWN+3hHreLg@mail.gmail.com>
	<1394292461.20149.55.camel@edumazet-glaptop2.roam.corp.google.com>
	<1394294883.20149.70.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Erez Zadok <ezk@fsl.cs.sunysb.edu>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Geoff Kuenning <geoff@cs.hmc.edu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:55826 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751610AbaCIAxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2014 19:53:03 -0500
Received: by mail-ie0-f182.google.com with SMTP id y20so5916816ier.27
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2014 16:53:02 -0800 (PST)
In-Reply-To: <1394294883.20149.70.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

We noticed many changes in the TCP stack, and a lot of them come from you :-)

Actually, we have a question about this patch you submitted
(http://lwn.net/Articles/564979/) regarding an experiment we conducted
in the 3.12.0 kernel. The results we observed in shown in the second
figure of panel 6 in this poster at
http://www.fsl.cs.sunysb.edu/~mchen/fast14poster-hashcast-portrait.pdf
.  We have repeated the same experiment for 100 times, and observed
that results like that appeared 4 times. For this experiment, we
observed that all five flows are using dedicated tx queues.  But what
makes a big difference is the average packet sizes of the flows.
Client4 has an average packet size of around 3KB while all other
clients generate packet sizes over 50KB. We suspect it might be caused
by this TSO Packets Automatic Sizing feaure. Our reasoning is this: if
a TCP flow starts slowly, this feature will assign it a small packet
size. The packet size and the sending rate can somehow form a feedback
loop, which can force the TCP flow's rate to stay low. What do you
think about this?

We have not tried the latest kernel yet. Frankly speaking, as a
networking layman, I am already overwhelmed by the complexity of the
TCP stack in the 3.12.0 kernel. I guess it is the nature of networking
if we are going to 40GbE or even 100GbE. But anyway, thanks for your
suggestion.

Best,
Ming

On Sat, Mar 8, 2014 at 11:08 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Also try more recent kernels. TCP stack changes a lot these days ;)
>
> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git
>
> contains many TCP related stuff which should land in linux-3.15
>
