From: P@draigBrady.com
Subject: Re: Luca Deri's paper: Improving Passive Packet Capture: Beyond Device
 Polling
Date: Tue, 06 Apr 2004 11:30:19 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <407286BB.8080107@draigBrady.com>
References: <20040330142354.GA17671@outblaze.com> <1081033332.2037.61.camel@jzny.localdomain> <c4rvvv$dbf$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, cpw@lanl.gov, luca.deri@netikos.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jason Lunz <lunz@falooley.org>
In-Reply-To: <c4rvvv$dbf$1@sea.gmane.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jason Lunz wrote:
> hadi@cyberus.ca said:
>=20
>>Jason Lunz actually seemed to have been doing more work on this and
>>e1000 - he could provide better perfomance numbers.
>=20
>=20
> Well, not really. What I have is still available at:
>=20
> http://gtf.org/lunz/linux/net/perf/
>=20
> ...but those are mainly measurements of very outdated versions of the
> e1000 napi driver backported to 2.4, running on 1.8Ghz Xeon systems.
> That work hasn't really been kept up to date, I'm afraid.
>=20
>=20
>>It should also be noted that infact packet mmap already uses rings.
>=20
>=20
> Yes, I read the paper (but not his code). What stood out to me is that
> the description of his custom socket implementation matches exactly wha=
t
> packet-mmap already is.
>=20
> I noticed he only mentioned testing of libpcap-mmap, but did not use
> mmap packet sockets directly -- maybe there's something about libpcap
> that limits performance? I haven't looked.

That's my experience. I'm thinking of redoing libpcap-mmap completely
as it has huge amounts of statistics messing in the fast path.
Also the ring gets corrupted if packets are being received while
the ring buffer is being setup.

I've a patch for http://public.lanl.gov/cpw/libpcap-0.8.030808.tar.gz
here: http://www.pixelbeat.org/patches/libpcap-0.8.030808-pb.diff
(you need to compile with PB defined)
Note this only addresses the speed issue.
Also there are newer versions of libpcap-mmap available which I
haven't looked at yet.

> What I can say for sure is that the napi + packet-mmap performance with
> many small packets is almost surely limited by problems with irq/softir=
q
> load. There was an excellent thread last week about this with Andrea
> Arcangeli, Robert Olsson and others about the balancing of softirq and
> userspace load; they eventually were beginning to agree that running
> softirqs on return from hardirq and bh was a bigger load than expected
> when there was lots of napi work to do. So despite NAPI, too much kerne=
l
> time is spent handling (soft)irq load with many small packets.

agreed.

> It appears this problem became worse in 2.6 with HZ=3D1000, because now
> the napi rx softirq work is being done 10X as much on return from the
> timer interrupt.  I'm not sure if a solution was reached.

P=E1draig.
