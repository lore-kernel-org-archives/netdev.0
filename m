From: Donald Becker <becker@scyld.com>
Subject: Re: 3c59x 2.4.18 userspace seeing UDP packets with bad checksum?
Date: Tue, 30 Jul 2002 10:09:13 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0207301002370.1266-100000@beohost.scyld.com>
References: <20020730134908.GA26100@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kuznet@ms2.inr.ac.ru, <netdev@oss.sgi.com>, <akpm@zip.com.au>,
   <jgarzik@mandrakesoft.com>
Return-path: <owner-netdev@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20020730134908.GA26100@outpost.ds9a.nl>
List-Id: netdev.vger.kernel.org

On Tue, 30 Jul 2002, bert hubert wrote:
> On Tue, Jul 30, 2002 at 05:31:44PM +0400, kuznet@ms2.inr.ac.ru wrote:
> 
> > Well, try to prove that corrupted packet is really received by application.
> > This is not useless work, in any case, you have to cure this place,
> > it should not abort because of invalid data. :-)
> 
> We fixed the bug already :-) Signed/unsigned arithmetic problems.

Were the arithmetic problems in your code, or the kernels checksumming?
(The latter seems unlikely.)

> I have six examples in my log of PowerDNS exiting just after receiving a
> packet with a broken checksum.

Wouldn't this have also happened with valid checksums and invalid data?
This is a good time to fix your application data validity checking.

Note that some network equipment will re-write the IP checksums, just as
some equipment regenerates the link-level frame CRC.  It's not
semantically correct, but claiming that such devices don't exist doesn't
make them go away.

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Second Generation Beowulf Clusters
Annapolis MD 21403			410-990-9993
