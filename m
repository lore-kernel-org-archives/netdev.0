From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: 2.5.70-bk+ broken networking
Date: Wed, 4 Jun 2003 23:33:49 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030605023349.GH24515@conectiva.com.br>
References: <20030604161437.2b4d3a79.shemminger@osdl.org> <3EDE7FEB.2C7FAEC7@digeo.com> <20030604185652.31958d1f.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, jgarzik@pobox.com, davem@redhat.com,
   netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@digeo.com>
Content-Disposition: inline
In-Reply-To: <20030604185652.31958d1f.akpm@digeo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Wed, Jun 04, 2003 at 06:56:52PM -0700, Andrew Morton escreveu:
> Andrew Morton <akpm@digeo.com> wrote:
> >
> > Stephen Hemminger wrote:
> > > 
> > > Test machine running 2.5.70-bk latest can't boot because eth2 won't
> > > come up.  The same machine and configuration successfully brings up
> > > all the devices and runs on 2.5.70.
> > 
> > kjournald is stuck waiting for IO to complete against some buffer
> > during transaction commit.
> > 
> > I'd be suspecting block layer or device drivers.  What device driver
> > is handling your /var/log?
> 
> I take that back.
> 
> Your sysrq-T woke up syslogd which did a synchronous write which poked
> kjournald.  You happened to catch it in mid-commit.  So that's all normal
> and sane.
> 
> Something is up with netdevice initialisation.  My eth0 (e100) is in a
> strange half-there state and won't come up.  Reverting the post-2.5.70 e100
> changes does not help.  It's something which went into the tree today I
> think.

Strange as I'm using 2.5.70-latest-bk as of 30 minutes ago, i.e. uptodate with
Linus + my network patches. Thing is related to nfs, please nfs loading at
boot time and try again, worked for me, don't know what is wrong with nfs
loading tho (haven't checked at all, just disabled loading of the nfs
server) :-(

- Arnaldo
