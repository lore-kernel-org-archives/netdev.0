From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: randconfig build error with next-20141112, in net/sched
Date: Thu, 13 Nov 2014 11:22:30 +0100
Message-ID: <1415874150.15503.5.camel@localhost>
References: <CA+r1ZhjMGJVSdp71pQ5aHjAvDDxDYBsgzmwcnt5oNyZTmdZDiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>, jhs@mojatatu.com,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jim Davis <jim.epost@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+r1ZhjMGJVSdp71pQ5aHjAvDDxDYBsgzmwcnt5oNyZTmdZDiw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mi, 2014-11-12 at 15:33 -0700, Jim Davis wrote:
> Building with the attached random configuration file,
> 
> ERROR: "reciprocal_value" [net/sched/sch_sfq.ko] undefined!
> ERROR: "reciprocal_value" [net/sched/sch_netem.ko] undefined!

Thanks for the report. I think moving reciproval_div.o from lib-y to
obj-y should resolve the problem. On it...

The problem with lib-y is, if vmlinux itself doesn't use the symbol,
even if it is EXPORT_SYMBOLED, it won't be linked into the kernel. You
seem to hit a configuration where reciproval_divide wasn't used in the
kernel at all but only in modules, as such it got purged from vmlinux
during linking.

Thanks,
Hannes
