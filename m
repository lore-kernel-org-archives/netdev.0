From: Alex Elsayed <eternaleye@gmail.com>
Subject: Re: [PATCH v2 0/2] RFC, aiding pid/network correlation
Date: Sat, 02 Aug 2014 19:47:36 -0700
Message-ID: <lrk7s8$88k$2@ger.gmane.org>
References: <1406856100-21674-1-git-send-email-pmoody@google.com> <87y4v876bs.fsf@synack.fr> <r3noaw4m8g6.fsf@perdido.sfo.corp.google.com> <lrhr02$ncj$1@ger.gmane.org> <r3nzjfmjr07.fsf@perdido.sfo.corp.google.com> <lrk4f5$4vo$2@ger.gmane.org> <r3nvbqajovk.fsf@perdido.sfo.corp.google.com> <lrk6or$unu$2@ger.gmane.org> <r3nr40yjo1e.fsf@perdido.sfo.corp.google.com> <lrk7gb$unu$4@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alex Elsayed wrote:

> Peter Moody wrote:
> 
>> 
>> On Sat, Aug 02 2014 at 19:28, Alex Elsayed wrote:
>> 
>>> Oh, I see now. Okay, that's actually considerably simpler - I just had
>>> somehow gotten it fixated into my mind that the info would be used to
>>> decide on allow/deny actions.
>>>
>>> The trick to do what you want is the 'audit' support in both -
>>> here I'll use CaitSith as an example since the syntax is nicer.
>> 
>> Do these audit logs end up with the audit subsystem? My experience with
>> the audit subsystem is that performance takes a big hit when you start
>> sending thousands (or even hundreds) of audit messages per second.
> 
> No, they go straight to /proc/caitsith/audit and wind up looking like
> this:
> 
> #2012/04/08 05:03:03# global-pid=3720 result=allowed priority=100 / read
> path="/tmp/file1" task.pid=3720 task.ppid=3653 task.uid=0 task.gid=0
> task.euid=0 task.egid=0 task.suid=0 task.sgid=0 task.fsuid=0 task.fsgid=0
> task.type!=execute_handler task.exe="/bin/cat"
> task.domain="/usr/sbin/sshd" path.uid=0 path.gid=0 path.ino=2113451
> path.major=8 path.minor=1 path.perm=0644 path.type=file
> path.fsmagic=0xEF53 path.parent.uid=0 path.parent.gid=0
> path.parent.ino=2097153 path.parent.major=8 path.parent.minor=1
> path.parent.perm=01777 path.parent.type=directory
> path.parent.fsmagic=0xEF53

Actually, now that I look at that, you'd need to audit 'domain transition' 
events too - since that contains all the relevant PIDs, then the most recent 
domain transition with all of the right PIDs is sufficient to rebuild the 
tree back to init (recursively)

