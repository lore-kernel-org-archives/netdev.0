From: Andi Kleen <ak@suse.de>
Subject: Re: Route cache performance under stress
Date: Wed, 11 Jun 2003 09:28:32 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030611072832.GC27144@wotan.suse.de>
References: <3EE67D2D.80608@candelatech.com> <20030610.180120.71112140.davem@redhat.com> <Pine.LNX.4.51.0306102115210.18076@ns.istop.com> <20030610.182338.41657455.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ralph+d@istop.com, ralph@istop.com, greearb@candelatech.com,
	Robert.Olsson@data.slu.se, hadi@shell.cyberus.ca, xerox@foonet.net,
	sim@netnation.com, fw@deneb.enyo.de, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030610.182338.41657455.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Tue, Jun 10, 2003 at 06:23:38PM -0700, David S. Miller wrote:
>    From: Ralph Doncaster <ralph@istop.com>
>    Date: Tue, 10 Jun 2003 21:17:28 -0400 (EDT)
> 
>    Aren't the read_lock_irqsave and restore expensive?
> 
> If x86 has an inefficient implementation, well... :-)

sti/cli is normally fast on x86, a bit slower on P3 core (a few cycles or so)
read_lock_irqsave does a pushfl though, that's rather slow on P4,
but still not that bad. read_lock_irq would be faster, but too risky 
here.

> 
> This can be done without locks, nobody has done the x86 implementation
> of that that's all.  I think the x86_64 folks did a lockless version,
> I know I did for sparc64 :)

2.5 i386 gettimeofday is lockless. But on UP it should not make any difference
anyways.

-Andi
