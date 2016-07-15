From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH 00/14] Present useful limits to user (v2)
Date: Fri, 15 Jul 2016 16:19:13 +0200
Message-ID: <5788F0E1.8090203@nod.at>
References: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jonathan Corbet <corbet@lwn.net>, Tony Luck <tony.luck@intel.com>,
 Fenghua Yu <fenghua.yu@intel.com>, Alexander Graf <agraf@suse.com>,
 Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?=
 <rkrcmar@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 "H. Peter Anvin" <hpa@zytor.com>,
 "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>,
 Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>,
 Hal Rosenstock <hal.rosenstock@gmail.com>,
 Mike Marciniszyn <mike.marciniszyn@intel.com>,
 Dennis Dalessandro <dennis.dalessandro@intel.com>,
 Christian Benvenuti <benve@cisco.com>, Dave Goodell <dgoodell@cisco.com>,
 Sudeep Dutt <sudeep.dutt@intel.com>,
 Ashutosh Dixit <ashutosh.dixit@inte
To: Topi Miettinen <toiwoton@gmail.com>, linux-kernel@vger.kernel.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Hi!

Am 15.07.2016 um 12:35 schrieb Topi Miettinen:
> Hello,
> 
> There are many basic ways to control processes, including capabilities,
> cgroups and resource limits. However, there are far fewer ways to find out
> useful values for the limits, except blind trial and error.
> 
> This patch series attempts to fix that by giving at least a nice starting
> point from the highwater mark values of the resources in question.
> I looked where each limit is checked and added a call to update the mark
> nearby.
> 
> Example run of program from Documentation/accounting/getdelauys.c:
> 
> ./getdelays -R -p `pidof smartd`
> printing resource accounting
> RLIMIT_CPU=0
> RLIMIT_FSIZE=0
> RLIMIT_DATA=18198528
> RLIMIT_STACK=135168
> RLIMIT_CORE=0
> RLIMIT_RSS=0
> RLIMIT_NPROC=1
> RLIMIT_NOFILE=55
> RLIMIT_MEMLOCK=0
> RLIMIT_AS=130879488
> RLIMIT_LOCKS=0
> RLIMIT_SIGPENDING=0
> RLIMIT_MSGQUEUE=0
> RLIMIT_NICE=0
> RLIMIT_RTPRIO=0
> RLIMIT_RTTIME=0
> 
> ./getdelays -R -C /sys/fs/cgroup/systemd/system.slice/smartd.service/
> printing resource accounting
> sleeping 1, blocked 0, running 0, stopped 0, uninterruptible 0
> RLIMIT_CPU=0
> RLIMIT_FSIZE=0
> RLIMIT_DATA=18198528
> RLIMIT_STACK=135168
> RLIMIT_CORE=0
> RLIMIT_RSS=0
> RLIMIT_NPROC=1
> RLIMIT_NOFILE=55
> RLIMIT_MEMLOCK=0
> RLIMIT_AS=130879488
> RLIMIT_LOCKS=0
> RLIMIT_SIGPENDING=0
> RLIMIT_MSGQUEUE=0
> RLIMIT_NICE=0
> RLIMIT_RTPRIO=0
> RLIMIT_RTTIME=0
> 
> In this example, smartd is running as a non-root user. The presented
> values can be used as a starting point for giving new limits to the
> service.

I don't think it is worth sprinkling the kernel with update_resource_highwatermark()
calls just to get these metrics.

Can't we teach the existing perf infrastructure to collect these highwatermarks for us?

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
