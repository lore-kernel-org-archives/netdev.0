From: Sanjoy Mahajan <sanjoy@MIT.EDU>
Subject: Re: e1000e fails after several S3 resumes (2.6.26
	Debian, TP T60)
Date: Fri, 24 Oct 2008 10:24:57 -0400
Message-ID: <E1KtNaz-0003Xx-0y@approx.mit.edu>
References: <F169D4F5E1F1974DBFAFABF47F60C10A069DFD62@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	NetDEV list <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: Your message of "Thu, 23 Oct 2008 15:42:55 PDT."
	<F169D4F5E1F1974DBFAFABF47F60C10A069DFD62@orsmsx507.amr.corp.intel.com>
	(sfid-20081023_194301_937814_89312B9F)
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> hm, does your kernel have CONFIG_PM defined?  

It does have that defined:

  $ grep CONFIG_PM /boot/config-2.6.26-1-686 
  CONFIG_PM=y
  # CONFIG_PM_DEBUG is not set
  CONFIG_PM_SLEEP_SMP=y
  CONFIG_PM_SLEEP=y
  CONFIG_PM_STD_PARTITION=""

> if it happens again please include lspci -vvv before and after ethtool
> -r (see below)

I will.  Now I'm running BIOS 2.23, so I'm curious whether that
'upgrade' fixes the problem.

I say 'upgrade' because now S3 sleep and wakeup often take 60 seconds.
I've also noticed ACPI errors in the 'dmesg'.  Once I have something
reproducible I'll file a bugzilla report.

> device was also claiming successfully transmitting, so I don't know
> why the DHCP packets don't work, can you tcpdump on the network or the
> dhcp server by chance?

I'll do that too on the next failure.  Is 'tcpdump host 18.38.0.1'
sufficient or do I need a few -v switches?

> can you ifconfig eth0 promisc before doing suspend?  I'd be curious if
> that fixed it.

If/when it reproduces, I'll add that line to the pre-suspend code.  (I
use 's2ram', which I think sleeps with 'echo mem > /sys/power/state' and
does a vt switch on wakeup).

Generally: For making debugging go smoothly, is it worth running a
vanilla kernel rather than the Debian one?  I could try 2.6.26.7 or
2.6.27.3.  Is running 2.6.27.y not as useful as running 2.6.26.y, in
case the bug is merely hidden but not solved in the new kernel?  On the
other hand, I'm tempted to try 2.6.27.y in case it fixes the slow
suspend/resume.

-Sanjoy

`Until lions have their historians, tales of the hunt shall always
 glorify the hunters.'  --African Proverb

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
