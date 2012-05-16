From: Omar Alhassane <oalhassane@gmail.com>
Subject: Re: PROBLEM: Fragmentation issue with 1521 bytes ip packets
Date: Wed, 16 May 2012 15:36:42 -0400
Message-ID: <CAPFXtPeMqznLajfdG6Cnubh6yfBieujhozV3xyjb+ZU71CUUNw@mail.gmail.com>
References: <CAPFXtPexGpVyGGuKdjpuH+cxOaxa7KeBfmFrs39=NW7LsZ6-bw@mail.gmail.com>
	<1337094259.8512.1100.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:55852 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760517Ab2EPTgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 15:36:42 -0400
Received: by yhmm54 with SMTP id m54so1127674yhm.19
        for <netdev@vger.kernel.org>; Wed, 16 May 2012 12:36:42 -0700 (PDT)
In-Reply-To: <1337094259.8512.1100.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you for explaining.

Omar

On Tue, May 15, 2012 at 11:04 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> On Tue, 2012-05-15 at 10:00 -0400, Omar Alhassane wrote:
> > Hello Folks,
> >
> > I think i may have found a problem with the linux networking stack.
> > Below is a description of the problem.
> >
> > [1.] One line summary of the problem:
> > No response to pings of certain sizes.
> >
> > [2.] Full description of the problem/report:
> > Using hping3, when i ping a linux machine with 1521 bytes ip packets i
> > get only one response.
> > But when i use 1482 bytes, everything works fine. I've tried this with
> > both tcp and udp. The MTU of my interface is 1500.
> > [3.] Keywords (i.e., modules, networking, kernel):
> > ip, udp, tcp, networking, fragmentation
> > [4.] Kernel version (from /proc/version):
> > 3.3.1
> > [5.] Output of Oops.. message (if applicable) with symbolic information
> > [6.] A small shell script or example program which triggers the
> > problem (if possible)
> > The following commands works only if the target has tcp port 22 open
> >
> > hping3 -d 1481 -S -P 22 10.0.30.225 (only one response)
> > hping3 -d 1482 -S -P 22 10.0.30.225 (works fine)
> >
> > Can somebody confirm if this is a problem?
>
> hping3 bug : All the fragments it sends have the same ID field.
>
> First 2 frags are reassembled by remote. Remote sends a SYNACK.
>
>
> Following frags are 'ignored' because they have same ID than previous
> packet.
>
>
>
>
>
