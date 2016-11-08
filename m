From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: Re: [lkp] [net]  af1fee9821:
 BUG:spinlock_trylock_failure_on_UP_on_CPU
Date: Tue, 8 Nov 2016 09:11:54 +0100
Message-ID: <20161108081154.GA22561@microsemi.com>
References: <20161107022628.GA21529@yexl-desktop>
 <20161107093148.GA27001@lunn.ch>
 <20161107132714.GA10669@microsemi.com>
 <20161108020151.GA16988@yexl-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Andrew Lunn <andrew@lunn.ch>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>,
        "David S. Miller" <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <lkp@01.org>
To: Ye Xiaolong <xiaolong.ye@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161108020151.GA16988@yexl-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ye Xiaolong,

On 08/11/16 10:01, Ye Xiaolong wrote:
> Could you tell us what troubles you have met when trying the "lkp qemu"
> tool, it would be better if you could paste some log so we can help to
> improve it.

Sure:

anielsen@lx-anielsen ~/work/opensource-phy/lkp-tests (master) $ bin/lkp qemu -k ../net-next/bug-build/arch/x86_64/boot/bzImage /home/anielsen/Downloads/job-script
/home/anielsen/Downloads/job-script: line 2: $'\r': command not found
/home/anielsen/Downloads/job-script: line 3: syntax error near unexpected token
`$'\r''
'home/anielsen/Downloads/job-script: line 3: `export_top_env()
mkdir: cannot create directory ‘/lkp’: Permission denied
mv: cannot stat ‘/home/anielsen/.lkp/cache/lkp-x86_64.cgz’: No such file or
directory
find: ‘/boot/lost+found’: Permission denied
^C

Looks like it expect unix-style line endings (not sure where it got converted to dos-style):

So I tried that (and created some of the missing folders):

$ dos2unix /home/anielsen/Downloads/job-script
$ sudo mkdir /lkp
$ sudo chmod 777 /lkp
$ bin/lkp qemu -k ../net-next/bug-build/arch/x86_64/boot/bzImage /home/anielsen/Downloads/job-script
make: Entering directory '/home/anielsen/work/opensource-phy/lkp-tests/bin/event'
klcc    -c -o wakeup.o wakeup.c
make: klcc: Command not found
<builtin>: recipe for target 'wakeup.o' failed
make: *** [wakeup.o] Error 127
make: Leaving directory '/home/anielsen/work/opensource-phy/lkp-tests/bin/event'
mv: cannot stat ‘/home/anielsen/.lkp/cache/lkp-x86_64.cgz’: No such file or directory
downloading initrds ...
/usr/bin/wget -q --local-encoding=UTF-8 --retry-connrefused --waitretry 1000 --tries 1000 https://github.com/0day-ci/lkp-qemu/raw/master/osimage/debian/debian-x86_64-2016-08-31.cgz -N -P /home/anielsen/.lkp/cache/osimage/debian
/usr/bin/wget -q --local-encoding=UTF-8 --retry-connrefused --waitretry 1000 --tries 1000 https://github.com/0day-ci/lkp-qemu/raw/master/osimage/deps/debian-x86_64-2016-08-31.cgz/lkp_2016-11-02.cgz -N -P /home/anielsen/.lkp/cache/osimage/deps/debian-x86_64-2016-08-31.cgz
Failed to download osimage/deps/debian-x86_64-2016-08-31.cgz/lkp_2016-11-02.cgz

Okay, so klcc is missing:
$ sudo emerge -av dev-libs/klibc
...
make -j8 prepare CC=x86_64-pc-linux-gnu-gcc HOSTCC=x86_64-pc-linux-gnu-gcc
scripts/kconfig/conf --silentoldconfig Kconfig
  CHK     include/linux/version.h
  UPD     include/linux/version.h
  CHK     include/generated/utsrelease.h
  UPD     include/generated/utsrelease.h
  CC      kernel/bounds.s
In file included from include/linux/compiler.h:48:0,
                 from include/linux/stddef.h:4,
                 from include/linux/posix_types.h:4,
                 from include/linux/types.h:17,
                 from include/linux/page-flags.h:8,
                 from kernel/bounds.c:9:
include/linux/compiler-gcc.h:90:30: fatal error: linux/compiler-gcc5.h: No such file or directory
compilation terminated.
...

And this is where I gave up (at least for now) - it is because I have not
installed my kernel using the packet system - that is my fault and I will get it
fixed.

I did see that you wrote in the readme.md that this needs to run as root - but
it did not look like a permission issue...

So, not very usefull feedback - I know - sorry.

I will get this fixed, give it another try and the get back to you.

/Allan
