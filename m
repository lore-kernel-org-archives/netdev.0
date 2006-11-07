From: "Zhao Xiaoming" <xiaoming.nj@gmail.com>
Subject: Re: ZONE_NORMAL memory exhausted by 4000 TCP sockets
Date: Tue, 7 Nov 2006 10:48:41 +0800
Message-ID: <f55850a70611061848g5f316399oe877a38705e7f99b@mail.gmail.com>
References: <f55850a70611052207j384e1d3flaf40bb9dd74df7c5@mail.gmail.com>
	 <200611061022.57840.dada1@cosmosbay.com>
	 <f55850a70611060146o1b2adcabq8c1313f6711f3f4e@mail.gmail.com>
	 <200611061433.50912.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"Linux Netdev List" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.203]:46612 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1753962AbWKGCsp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Nov 2006 21:48:45 -0500
Received: by nz-out-0102.google.com with SMTP id z3so995007nzf
        for <netdev@vger.kernel.org>; Mon, 06 Nov 2006 18:48:44 -0800 (PST)
In-Reply-To: <200611061433.50912.dada1@cosmosbay.com>
Content-Disposition: inline
To: unlisted-recipients:; (no To-header on input)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/6/06, Eric Dumazet <dada1@cosmosbay.com> wrote:
> On Monday 06 November 2006 10:46, Zhao Xiaoming wrote:
> > 2006/11/6, Eric Dumazet <dada1@cosmosbay.com>:
> > > On Monday 06 November 2006 09:59, Zhao Xiaoming wrote:
> > > > Thank you again for your help. To have more detailed statistic data, I
> > > > did another round of test and gathered some data.  I give the overall
> > > > description here and detailed /proc/net/sockstat, /proc/meminfo,
> > > > /proc/slabinfo and /proc/buddyinfo follows.
> > > > =====================================================
> > > >                            slab mem cost        tcp mem pages
> > > > lowmem free with traffic:             254668KB                 34693
> > > >       38772KB
> > > > without traffic:       104080KB                           1
> > > >        702652KB
> > > > =====================================================
> > >
> > > Thank you for detailed infos.
> > >
> > > It appears you have an extensive use of threads (about 10000), since :
> > > > task_struct        10095  10095   1360    3    1 : tunables   24   12
> > > >   8 : slabdata   3365   3365      0
> > >
> > > Each thread has a kernel stack, 8KB (ie 2 pages, order-1 allocation),
> > > plus a user vma
> > >
> > > > vm_area_struct     21346  21504     92   42    1 : tunables  120   60
> > > >   8 : slabdata    512    512      0
> > >
> > > Most likely you dont need that much threads. A program with fewer threads
> > > will perform better and use less ram.
> >
> > Thanks for the comments. I known the threads may cost many memory.
> > However, I already excluded them from the statistics. The 'after test'
> > info was gotten while the 10000 threads running but no traffics
> > relayed. You may look at the meminfo of 'after test', there is still
> > 104080 kB slab memory which should already included the thread kernel
> > memory cost (8K*10000=80MB). I know 10000 threads are not necessary
> > and just use the simple logic to do some test.
>
> In fact, your kernel has CONFIG_4KSTACKS, kernel thread stacks use 4K instead
> of 8K.
>
> If you want to increase LOWMEM, (and keep 32bits kernel), you can chose a
> 2G/2G user/kernel split, instead of the 3G/1G default split.
> (see config : CONFIG_VMSPLIT_2G)
>
> Eric
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
Thank you for your advice. I know increase LOMEM could be help, but
now my concern is why I lose my 500M bytes memory after excluding all
known memory cost.
