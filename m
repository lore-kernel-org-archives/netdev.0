From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/59] Cleanup sysctl
Date: Wed, 17 Jan 2007 12:02:27 -0700
Message-ID: <m1y7o18ojg.fsf@ebiederm.dsl.xmission.com>
References: <m1ac0jc4no.fsf@ebiederm.dsl.xmission.com>
	<45AE66AA.1050508@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, James.Bottomley@SteelEye.com,
	linux-mips@linux-mips.org, linux-parport@lists.infradead.org,
	minyard@acm.org, rtc-linux@googlegroups.com, clemens@ladisch.de,
	heiko.carstens@de.ibm.com, xfs@oss.sgi.com,
	linuxppc-dev@ozlabs.org, paulus@samba.org,
	openipmi-developer@lists.sourceforge.net, linux-390@vm.marist.edu,
	schwidefsky@de.ibm.com, tim@cyberelk.net,
	codalist@TELEMANN.coda.cs.cmu.edu, a.zummo@towertech.it,
	tony.luck@intel.com, vojtech@suse.cz, linux-scsi@vger.kernel.org,
	xfs-masters@oss.sgi.com, linux-ntfs-dev@lists.sourceforge.net,
	netdev@vger.kernel.org, aia21@cantab.net, aharkes@cs.cmu.edu,
	linux-kernel@vger.kernel.org, ralf@linux-mips.org,
	mark.fasheh@oracle.com, coda@cs.cmu.edu, lethal@linux-sh.org,
	kurt.hackel@oracle.com,
	Linux Containers <containers@lists.osdl.org>,
	linux390@de.ibm.com, philb@gnu.org, andrea@suse.de,
	linuxsh-shmed
Return-path: <linux-mips-bounce@linux-mips.org>
To: Kirill Korotaev <dev@sw.ru>
In-Reply-To: <45AE66AA.1050508@sw.ru> (Kirill Korotaev's message of "Wed, 17
	Jan 2007 21:10:50 +0300")
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

Kirill Korotaev <dev@sw.ru> writes:

> Eric, really good job!
>
> Patches: 1-13, 15-24, 26-32, 34-44, 46-49, 52-55, 57 (all except below)
> Acked-By: Kirill Korotaev <dev@openvz.org>
>
> 14/59 - minor (extra space)
> 25/59 - minor note	
> 33/59 - not sorted sysctl IDs
> 45/59 - typo
> 50/59 - copyright/file note
> 51/59 - copyright/file name/kconfig option notes
>
> 56,58,59/59 - will review tomorrow
>
> another issue I have to think over is removal of de->owner.
> Alexey Dobriyan has sent recently patching fixing /proc <-> modules refcounting.
> I guess w/o these patches your changes are not safe if proc_handler or strategy
> are functions from the module.

sysctl uses the logic in use_table/unuse_table to keep it safe from module
remove while it is in use.  And it does the logic in the generic code
in either do_rw_proc or do_sysctl.  This definitely works on the sys_sysctl path
and it appears to work in the do_rw_proc case, things are a little trickier
there so someone may have missed a race somewhere.  In my rewrite of proc
it works exactly like the binary case so we are good there. 

It is certainly the intention of the sysctl implementation that users
should not have to set de->owner.  So if there is a problem with 
removing de->owner it is a bug in the sysctl implementation not in
the code where it was removed.

Normal proc users definitely have to set de->owner to be safe, but sysctl has
always been it's own thing, with different rules. 

Eric
