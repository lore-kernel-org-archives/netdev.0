From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: High CPU utilization with Bonding driver ?
Date: Tue, 5 Apr 2005 12:04:56 -0700
Message-ID: <002a01c53a12$5b876770$3a10100a@pc.s2io.com>
References: <Pine.LNX.4.61.0504042000050.13673@linux.site>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <bonding-devel@lists.sourceforge.net>,
        "'Leonid. Grossman \(E-mail\)'" <leonid.grossman@neterion.com>,
        "'Raghavendra. Koushik \(E-mail\)'" <raghavendra.koushik@neterion.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Arthur Kepner'" <akepner@sgi.com>
In-Reply-To: <Pine.LNX.4.61.0504042000050.13673@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Arthur,
The problem does not seem to be due to your patch because
the bonding driver built without your patch crashes too on load.
However, the pre-existing binary under /lib/modules/`uname -r`/...
works fine.
Any idea why this may be happening ?

Given below is the output of trying to insmod the bonding driver.

linux:/usr/src/linux-2.6.5-7.135/drivers/net/bonding # insmod bonding.ko
mode=4 miimon=100
Killed
linux:/usr/src/linux-2.6.5-7.135/drivers/net/bonding #
Message from syslogd@linux at Tue Apr  5 03:28:53 2005 ...
linux kernel: Oops: 0002 [1] SMP

Message from syslogd@linux at Tue Apr  5 03:28:53 2005 ...
linux kernel: CR2: ffffffffa0245000

linux:/usr/src/linux-2.6.5-7.135/drivers/net/bonding # dmesg|tail -25
Unable to handle kernel paging request at ffffffffa0245000 RIP:
<ffffffff8015afac>{sys_init_module+3388}
PML4 103027 PGD 105027 PMD f988c067 PTE 0
Oops: 0002 [1] SMP
CPU 2
Pid: 6608, comm: insmod Tainted: GF U (2.6.5-7.135-smp
SLES9_SP1_BRANCH-20041215213001)
RIP: 0010:[<ffffffff8015afac>] <ffffffff8015afac>{sys_init_module+3388}
RSP: 0018:000001007e17bd88  EFLAGS: 00010207
RAX: ffffffffa0244f00 RBX: ffffff000080b2d8 RCX: ffffffffa0244580
RDX: 0000000000000014 RSI: ffffff000081362b RDI: ffffffffa0243de3
RBP: ffffffffa0242e40 R08: 0000000000000018 R09: ffffffffa0246000
R10: 0000000000000001 R11: 000001003fffeda8 R12: 0000000000000018
R13: 7fffffffffffffff R14: ffffffff803d46c0 R15: 0000000000000002
FS:  0000002a9588f6e0(0000) GS:ffffffff80552d00(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: ffffffffa0245000 CR3: 00000000bff90000 CR4: 00000000000006e0
Process insmod (pid: 6608, threadinfo 000001007e17a000, task
000001007ea17400)
Stack: 000001007f136c00 8000000000106025 0000010001003950 000001003d7ec340
       00000100bf5debe8 0000000000000246 000001007ea17400 ffffffff8013cb20
       000001007e17bdc8 000001007e17bdc8
Call Trace:<ffffffff8013cb20>{autoremove_wake_function+0}
<ffffffff80179641>{do_munmap+1249}
       <ffffffff801106d4>{system_call+124}

Code: c7 80 00 01 00 00 00 00 00 00 48 83 e8 80 83 fa 3f 76 eb 65
RIP <ffffffff8015afac>{sys_init_module+3388} RSP <000001007e17bd88>
CR2: ffffffffa0245000


-----Original Message-----
From: Arthur Kepner [mailto:akepner@sgi.com]
Sent: Monday, April 04, 2005 8:03 PM
To: Ravinandan Arakali
Cc: netdev@oss.sgi.com; bonding-devel@lists.sourceforge.net; 'Leonid.
Grossman (E-mail)'; 'Raghavendra. Koushik (E-mail)'
Subject: RE: High CPU utilization with Bonding driver ?



On Mon, 4 Apr 2005, Ravinandan Arakali wrote:

> Arthur,
> On what kernel version should your below mentioned patch be applied ?
> We tried on one of the older kernels(2.6.5) and got an Oops while
> loading the bonding driver.
> .....

Hmmm, interesting.

I've used it with 2.6.X for at least two values of X (one of them
being 5) so I'm surprised. Can you provide details about the oops?

--

Arthut
