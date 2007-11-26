From: Wagner Ferenc <wferi@niif.hu>
Subject: Re: bonding sysfs output
Date: Mon, 26 Nov 2007 09:29:40 +0100
Message-ID: <87lk8lflzf.fsf@szonett.ki.iif.hu>
References: <87tznafjeu.fsf@szonett.ki.iif.hu>
	<20071125205150.4e49915f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754454AbXKZIaA@vger.kernel.org>
In-Reply-To: <20071125205150.4e49915f.akpm@linux-foundation.org> (Andrew
	Morton's message of "Sun, 25 Nov 2007 20:51:50 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Sun, 25 Nov 2007 16:12:57 +0100 Wagner Ferenc <wferi@niif.hu> wrote:
>
>> I propose it as a fix for trailing NULs and spaces like eg.
>> 
>> $ od -c /sys/class/net/bond0/bonding/slaves 
>> 0000000   e   t   h   -   l   e   f   t       e   t   h   -   r   i   g
>> 0000020   h   t      \n  \0
>> 0000025
>> 
>> I'm afraid there're other problems with "++more++" handling, but let's
>> not consider those just yet.  Find the patch attached.  The first
>> hunks also renames buffer to buf, for consistency's shake.
>> 
>> The original version had varying behaviour for Not Applicable cases.
>> This patch also settles for empty files (not even a line feed) in
>> those cases, but I'm not sure about the general policy on this matter.
>
> hm, there are a lot of changes there.  Were they all actually needed to fix
> the one bug which you have described?

Trailing NULs are present in each file under /sys/class/net/*/bonding
and also in /sys/class/net/bonding_masters.  That is, in every file
provided by drivers/net/bonding/bond_sysfs.c.  Most of the patch is
concerned with this.

Closely related is the presence of trailing spaces in multivalue
files.  There are three such files, one of them has the trailing space
removed.  This patch removes it from the other two.  During this it
also renames one function argument 'buffer' to 'buf', for consistency.

On the policy side: some files are not applicable to some types of
bonds, and return a single linefeed in that case.  Except for one
single case, which returns 'NA\n'.  The patch changes these cases into
emtpy files.

If these are worthy changes, I'm absolutely willing to split up the
patch into three parts as the above.
-- 
Thanks,
Feri.
