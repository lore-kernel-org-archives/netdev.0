From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.70-bk+ broken networking
Date: Wed, 4 Jun 2003 18:56:52 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030604185652.31958d1f.akpm@digeo.com>
References: <20030604161437.2b4d3a79.shemminger@osdl.org>
	<3EDE7FEB.2C7FAEC7@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: shemminger@osdl.org, jgarzik@pobox.com, davem@redhat.com,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org
In-Reply-To: <3EDE7FEB.2C7FAEC7@digeo.com>
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@digeo.com> wrote:
>
> Stephen Hemminger wrote:
> > 
> > Test machine running 2.5.70-bk latest can't boot because eth2 won't
> > come up.  The same machine and configuration successfully brings up
> > all the devices and runs on 2.5.70.
> 
> kjournald is stuck waiting for IO to complete against some buffer
> during transaction commit.
> 
> I'd be suspecting block layer or device drivers.  What device driver
> is handling your /var/log?

I take that back.

Your sysrq-T woke up syslogd which did a synchronous write which poked
kjournald.  You happened to catch it in mid-commit.  So that's all normal
and sane.

Something is up with netdevice initialisation.  My eth0 (e100) is in a
strange half-there state and won't come up.  Reverting the post-2.5.70 e100
changes does not help.  It's something which went into the tree today I
think.
