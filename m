From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: Spinlock spinning in __inet_hash_connect
Date: Wed, 6 Mar 2013 11:17:39 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B717A@saturn3.aculab.com>
References: <CAKF7Hnf_EyF38OEKk2rJEvEvn+eftJ4CaHN7-SszqbZius81yg@mail.gmail.com> <kh786e$r70$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: "Cong Wang" <xiyou.wangcong@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:37233 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756903Ab3CFLTg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 06:19:36 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 08937-07 for <netdev@vger.kernel.org>;
 Wed,  6 Mar 2013 11:19:30 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <kh786e$r70$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Wed, 06 Mar 2013 at 09:52 GMT, Johannes Rudolph <johannes.rudolph@googlemail.com> wrote:
> > Hello all,
> >
> > I hope I'm on the correct mailing list for raising this issue. We are
> > seeing an issue while running a load test with jmeter against a web
> > server [1]. The test suite uses 50 threads to connect to a localhost
> > web server, runs one http request per connection and then loops. What
> > happens is that after the test runs for about 10 seconds (~ 100000
> > connections established / closed) the CPU load goes up and connection
> > rates slow down massively (see [1] for a chart). With `perf top` I'm
> > observing this on the _client_ side:
> >
> >  41.39%  [kernel]                                    [k] __ticket_spin_lock
> >  16.83%  [kernel]                                    [k]
> > __inet_check_established
> >  12.50%  [kernel]                                    [k] __inet_hash_connect
> >   4.35%  [kernel]                                    [k] __ticket_spin_unlock
> >
> 
> It seems both IPv6 and IPv4 call paths contest for spin_lock(&head->lock),
> so I am just wondering if we could use RCU to protect the iteration of
> inet_bind_bucket_for_each().

I'd guess that the code is having 'difficultly' allocating
port numbers.
No amount of fiddling with locking will fix that.
There are probably a lot of sockets in one of the 'wait' states.

	David
