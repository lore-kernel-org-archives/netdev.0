From: Ralph Doncaster <ralph@istop.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 21:17:28 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.51.0306102115210.18076@ns.istop.com>
References: <20030610.152020.59678979.davem@redhat.com>
 <Pine.LNX.4.51.0306101956520.7801@ns.istop.com> <3EE67D2D.80608@candelatech.com>
 <20030610.180120.71112140.davem@redhat.com>
Reply-To: ralph+d@istop.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "greearb@candelatech.com" <greearb@candelatech.com>,
	"Robert.Olsson@data.slu.se" <Robert.Olsson@data.slu.se>,
	"hadi@shell.cyberus.ca" <hadi@shell.cyberus.ca>,
	"xerox@foonet.net" <xerox@foonet.net>,
	"sim@netnation.com" <sim@netnation.com>,
	"fw@deneb.enyo.de" <fw@deneb.enyo.de>,
	"netdev@oss.sgi.com" <netdev@oss.sgi.com>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030610.180120.71112140.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Tue, 10 Jun 2003, David S. Miller wrote:

> TSC do_gettimeofday() is REALLY cheap (TSC read plus a multiply which
> x86 does in like 5 cycles).

Aren't the read_lock_irqsave and restore expensive?

        read_lock_irqsave(&xtime_lock, flags);
        usec = do_gettimeoffset();
        {
                unsigned long lost = jiffies - wall_jiffies;
                if (lost)
                        usec += lost * (1000000 / HZ);
        }
        sec = xtime.tv_sec;
        usec += xtime.tv_usec;
        read_unlock_irqrestore(&xtime_lock, flags);

