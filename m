From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH V2 0/3] basic busy polling support for vhost_net
Date: Mon, 25 Jan 2016 16:41:33 +0800
Message-ID: <56A5DFBD.4000701@redhat.com>
References: <1448951985-12385-1-git-send-email-jasowang@redhat.com>
	<loom.20160124T095157-151@post.gmane.org> <56A58FB5.8020101@redhat.com>
	<OF39FCBD95.AC4D3DD2-ONC2257F45.002772D2-C2257F45.002BD839@il.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Michael Rapoport <RAPOPORT@il.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <OF39FCBD95.AC4D3DD2-ONC2257F45.002772D2-C2257F45.002BD839@il.ibm.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org



On 01/25/2016 03:58 PM, Michael Rapoport wrote:
> (restored 'CC, sorry for dropping it originally, Notes is still hard
> for me)
>
> > Jason Wang <jasowang@redhat.com> wrote on 01/25/2016 05:00:05 AM:
> > On 01/24/2016 05:00 PM, Mike Rapoport wrote:
> > > Hi Jason,
> > >
> > >> Jason Wang <jasowang <at> redhat.com> writes:
> > >>
> > >> Hi all:
> > >>
> > >> This series tries to add basic busy polling for vhost net. The
> idea is
> > >> simple: at the end of tx/rx processing, busy polling for new tx added
> > >> descriptor and rx receive socket for a while.
> > > There were several conciens Michael raised on the Razya's attempt
> to add
> > > polling to vhost-net ([1], [2]). Some of them seem relevant for these
> > > patches as well:
> > >
> > > - What happens in overcommit scenarios?
> >
> > We have an optimization here: busy polling will end if more than one
> > processes is runnable on local cpu. This was done by checking
> > single_task_running() in each iteration. So at the worst case, busy
> > polling should be as fast as or only a minor regression compared to
> > normal case. You can see this from the last test result.
> >
> > > - Have you checked the effect of polling on some macro benchmarks?
> >
> > I'm not sure I get the question. Cover letters shows some benchmark
> > result of netperf. What do you mean by "macro benchmarks"?
>
> Back then, when Razya posted her polling implementation, Michael had
> concern about the macro effect ([3]),
> so I was wondering if this concern is also valid for your implementation.
> Now, after I've reread your changes, I think it's not that relevant...

More benchmarks is good, but lots of kernel patches were accepted only
with simple netperf results. Anyway busy polling is disabled by default,
will try to do macro benchmark in the future if I had time.

>
>
> > >> The maximum number of time (in us) could be spent on busy polling was
> > >> specified ioctl.
> > > Although ioctl is definitely more appropriate interface to allow
> user to
> > > tune polling, it's still not clear for me how *end user* will
> interact with
> > > it and how easy it would be for him/her.
> >
> > There will be qemu part of the codes for end user. E.g. a vhost_poll_us
> > parameter for tap like:
> >
> > -netdev tap,id=hn0,vhost=on,vhost_pull_us=20
>
> Not strictly related, I'd like to give a try to polling + vhost thread
> sharing and polling + workqueues.
> Do you mind sharing the scripts you used to test the polling?

Sure, it was a subtest of autotest[1].

[1]
https://github.com/autotest/tp-qemu/blob/7cf589b490aff7511eccbf2e1336ecf8d9fa9cb9/generic/tests/netperf.py

>
>  
> Thanks,
> Mike.
>
> > Thanks
> >
> > >
> > > [1] http://thread.gmane.org/gmane.linux.kernel/1765593
> > > [2] http://thread.gmane.org/gmane.comp.emulators.kvm.devel/131343
> > >
> > > --
> > > Sincerely yours,
> > > Mike.
> > >
>
> [3] https://www.mail-archive.com/kvm@vger.kernel.org/msg109703.html
