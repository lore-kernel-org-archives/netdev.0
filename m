From: Michael Rapoport <RAPOPORT@il.ibm.com>
Subject: Re: [PATCH V2 0/3] basic busy polling support for vhost_net
Date: Mon, 25 Jan 2016 09:58:54 +0200
Message-ID: <OF39FCBD95.AC4D3DD2-ONC2257F45.002772D2-C2257F45.002BD839@il.ibm.com>
References: <1448951985-12385-1-git-send-email-jasowang@redhat.com>
	<loom.20160124T095157-151@post.gmane.org>
	<56A58FB5.8020101@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5544471525020863535=="
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <56A58FB5.8020101@redhat.com>
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

This is a multipart message in MIME format.
--===============5544471525020863535==
Content-Type: multipart/alternative; boundary="=_alternative 002BD700C2257F45_="

This is a multipart message in MIME format.
--=_alternative 002BD700C2257F45_=
Content-Type: text/plain; charset="US-ASCII"

(restored 'CC, sorry for dropping it originally, Notes is still hard for 
me)

> Jason Wang <jasowang@redhat.com> wrote on 01/25/2016 05:00:05 AM:
> On 01/24/2016 05:00 PM, Mike Rapoport wrote:
> > Hi Jason,
> >
> >> Jason Wang <jasowang <at> redhat.com> writes:
> >>
> >> Hi all:
> >>
> >> This series tries to add basic busy polling for vhost net. The idea 
is
> >> simple: at the end of tx/rx processing, busy polling for new tx added
> >> descriptor and rx receive socket for a while.
> > There were several conciens Michael raised on the Razya's attempt to 
add
> > polling to vhost-net ([1], [2]). Some of them seem relevant for these
> > patches as well:
> >
> > - What happens in overcommit scenarios?
> 
> We have an optimization here: busy polling will end if more than one
> processes is runnable on local cpu. This was done by checking
> single_task_running() in each iteration. So at the worst case, busy
> polling should be as fast as or only a minor regression compared to
> normal case. You can see this from the last test result.
> 
> > - Have you checked the effect of polling on some macro benchmarks?
> 
> I'm not sure I get the question. Cover letters shows some benchmark
> result of netperf. What do you mean by "macro benchmarks"?

Back then, when Razya posted her polling implementation, Michael had 
concern about the macro effect ([3]),
so I was wondering if this concern is also valid for your implementation.
Now, after I've reread your changes, I think it's not that relevant...

> >> The maximum number of time (in us) could be spent on busy polling was
> >> specified ioctl.
> > Although ioctl is definitely more appropriate interface to allow user 
to
> > tune polling, it's still not clear for me how *end user* will interact 
with
> > it and how easy it would be for him/her.
> 
> There will be qemu part of the codes for end user. E.g. a vhost_poll_us
> parameter for tap like:
> 
> -netdev tap,id=hn0,vhost=on,vhost_pull_us=20

Not strictly related, I'd like to give a try to polling + vhost thread 
sharing and polling + workqueues.
Do you mind sharing the scripts you used to test the polling?
 
Thanks,
Mike.

> Thanks
> 
> >
> > [1] http://thread.gmane.org/gmane.linux.kernel/1765593
> > [2] http://thread.gmane.org/gmane.comp.emulators.kvm.devel/131343
> >
> > --
> > Sincerely yours,
> > Mike.
> >

[3] https://www.mail-archive.com/kvm@vger.kernel.org/msg109703.html 

--=_alternative 002BD700C2257F45_=
Content-Type: text/html; charset="US-ASCII"

<tt><font size=2>(restored 'CC, sorry for dropping it originally, Notes
is still hard for me)</font></tt>
<br>
<br><tt><font size=2>&gt; Jason Wang &lt;jasowang@redhat.com&gt; wrote
on 01/25/2016 05:00:05 AM:<br>
&gt; On 01/24/2016 05:00 PM, Mike Rapoport wrote:<br>
&gt; &gt; Hi Jason,<br>
&gt; &gt;<br>
&gt; &gt;&gt; Jason Wang &lt;jasowang &lt;at&gt; redhat.com&gt; writes:<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; Hi all:<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; This series tries to add basic busy polling for vhost net.
The idea is<br>
&gt; &gt;&gt; simple: at the end of tx/rx processing, busy polling for
new tx added<br>
&gt; &gt;&gt; descriptor and rx receive socket for a while.<br>
&gt; &gt; There were several conciens Michael raised on the Razya's attempt
to add<br>
&gt; &gt; polling to vhost-net ([1], [2]). Some of them seem relevant for
these<br>
&gt; &gt; patches as well:<br>
&gt; &gt;<br>
&gt; &gt; - What happens in overcommit scenarios?<br>
&gt; <br>
&gt; We have an optimization here: busy polling will end if more than one<br>
&gt; processes is runnable on local cpu. This was done by checking<br>
&gt; single_task_running() in each iteration. So at the worst case, busy<br>
&gt; polling should be as fast as or only a minor regression compared to<br>
&gt; normal case. You can see this from the last test result.<br>
&gt; <br>
&gt; &gt; - Have you checked the effect of polling on some macro benchmarks?<br>
&gt; <br>
&gt; I'm not sure I get the question. Cover letters shows some benchmark<br>
&gt; result of netperf. What do you mean by &quot;macro benchmarks&quot;?<br>
</font></tt>
<br><tt><font size=2>Back then, when Razya posted her polling implementation,
Michael had concern about the macro effect ([3]),</font></tt>
<br><tt><font size=2>so I was wondering if this concern is also valid for
your implementation.</font></tt>
<br><tt><font size=2>Now, after I've reread your changes, I think it's
not that relevant...</font></tt>
<br><tt><font size=2><br>
&gt; &gt;&gt; The maximum number of time (in us) could be spent on busy
polling was<br>
&gt; &gt;&gt; specified ioctl.<br>
&gt; &gt; Although ioctl is definitely more appropriate interface to allow
user to<br>
&gt; &gt; tune polling, it's still not clear for me how *end user* will
interact with<br>
&gt; &gt; it and how easy it would be for him/her.<br>
&gt; <br>
&gt; There will be qemu part of the codes for end user. E.g. a vhost_poll_us<br>
&gt; parameter for tap like:<br>
&gt; <br>
&gt; -netdev tap,id=hn0,vhost=on,vhost_pull_us=20<br>
</font></tt>
<br><tt><font size=2>Not strictly related, I'd like to give a try to polling
+ vhost thread sharing and polling + workqueues.</font></tt>
<br><tt><font size=2>Do you mind sharing the scripts you used to test the
polling?</font></tt>
<br><tt><font size=2>&nbsp;</font></tt>
<br><tt><font size=2>Thanks,</font></tt>
<br><tt><font size=2>Mike.</font></tt>
<br><tt><font size=2><br>
&gt; Thanks<br>
&gt; <br>
&gt; &gt;<br>
&gt; &gt; [1] </font></tt><a href=http://thread.gmane.org/gmane.linux.kernel/1765593><tt><font size=2>http://thread.gmane.org/gmane.linux.kernel/1765593</font></tt></a><tt><font size=2><br>
&gt; &gt; [2] </font></tt><a href=http://thread.gmane.org/gmane.comp.emulators.kvm.devel/131343><tt><font size=2>http://thread.gmane.org/gmane.comp.emulators.kvm.devel/131343</font></tt></a><tt><font size=2><br>
&gt; &gt;<br>
&gt; &gt; --<br>
&gt; &gt; Sincerely yours,<br>
&gt; &gt; Mike.<br>
&gt; &gt;<br>
<br>
[3] </font></tt><a href="https://www.mail-archive.com/kvm@vger.kernel.org/msg109703.html"><tt><font size=2 color=blue>https://www.mail-archive.com/kvm@vger.kernel.org/msg109703.html</font></tt></a><tt><font size=2>
<br>
</font></tt>
--=_alternative 002BD700C2257F45_=--


--===============5544471525020863535==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============5544471525020863535==--
