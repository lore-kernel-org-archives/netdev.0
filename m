From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v1] net-sysfs: expose number of link up/down transitions
Date: Fri, 28 Mar 2014 10:46:16 -0700
Message-ID: <1396028776.12610.341.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1395980768.git.decot@googlers.com>
	 <cc4b88e880d31d8d71a5c8872a64c9d665cd097e.1395980768.git.decot@googlers.com>
	 <20140328062537.GA2805@minipsycho.orion>
	 <CAGVrzcZEuTCN0gtQ6pOSgT_3cd3Z8Z4OP2jn0QOD-QHbyPsAiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>,
	David Decotigny <decot@googlers.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Eric Dumazet <edumazet@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Weilong Chen <chenweilong@huawei.com>,
	Amir Vadai <amirv@mellanox.com>,
	Michael Dalton <mwdalton@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGVrzcZEuTCN0gtQ6pOSgT_3cd3Z8Z4OP2jn0QOD-QHbyPsAiA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-03-28 at 09:51 -0700, Florian Fainelli wrote:
> 2014-03-27 23:25 GMT-07:00 Jiri Pirko <jiri@resnulli.us>:
> >
> > If this is exposed in sysfs, this needs to be exposed via RT netlink as
> > well.
> 
> This makes me wonder if this really needs to be a kernel-maintained
> pair of counters. Since this seems to be useful for monitoring e.g:
> servers for link flapping, I would assume that some user-space
> script/program does read these sysfs entries periodically to report a
> healthy link. If that's the case, what prevents the same
> script/program from listening to netlink events and count the link
> UP/DOWN events from there and report that?

The same would be true for any counter in networking stack...

I do not feel we need to have a daemon running to 'count' events.

I like being able to run "ip -s link" , "ifconfig -a" or "nstat -a"
without having to connect to a daemon. This daemon will likely have
different api / constraints from distro to distro.

To me, first thing is a counter, then eventually events for daemons.

drop_monitor could eventually disappear if we had counters everywhere we
need them.
