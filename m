From: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
Subject: Re: [PATCH v2 2/2] checkpatch: suggest using eth_zero_addr() and
 eth_broadcast_addr()
Date: Thu, 23 Apr 2015 21:53:12 +0200
Message-ID: <55394DA8.3060705@gmail.com>
References: <1429481816-6664-1-git-send-email-mateusz.kulikowski@gmail.com>	 <1429481816-6664-3-git-send-email-mateusz.kulikowski@gmail.com>	 <1429492384.27863.13.camel@perches.com> <5536B9D2.7030200@gmail.com>	 <1429651348.31675.12.camel@perches.com> <5536C4C2.4000001@gmail.com> <1429655247.31675.20.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: apw@canonical.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429655247.31675.20.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22.04.2015 00:27, Joe Perches wrote:
> On Tue, 2015-04-21 at 23:44 +0200, Mateusz Kulikowski wrote:
>> On 21.04.2015 23:22, Joe Perches wrote:
>>> On Tue, 2015-04-21 at 22:57 +0200, Mateusz Kulikowski wrote:
>> (...)
(...)
>> True, True; If you prefer $line and ability to --fix - I'll use that in v3
> 
> I suppose you could do both $line and $stat
> and the fix would only work when it's on a
> single line.
> 
> Perhaps something like this would work:
> 
> 	if ($line =~ /whatever/ ||
> 	    (defined($stat) && $stat =~ /whatever/)) {
> 		if (WARN(...) &&
> 		    $fix) {
> 			fixed[$fixlinenr] =~ s/whatever/appropriate/;
> 		}
> 	}

Isn't it enough to just match $stat and do fix for line (that in 
some cases will just not match)?


One more thing
I noticed funny behavior about $stat matches - 
it reports the same error several times (including as "scope" whole file)
Is it feature or "feature" or I missed something?

Ex. file:
-------------- cut
int foo(void)
{
baz();
memset(a, b, 0);
bar();
}
-------------- cut

Output of (@master) 

-------------- cut
$ scripts/checkpatch.pl -f test42.c --types MEMSET
ERROR: memset to 0's uses 0 as the 2nd argument, not the 3rd
#1: FILE: test42.c:1:
+int foo(void)
 {
 baz();
 memset(a, b, 0);
 bar();
 }

ERROR: memset to 0's uses 0 as the 2nd argument, not the 3rd
#2: FILE: test42.c:2:
+{
 baz();
 memset(a, b, 0);
 bar();
 }

ERROR: memset to 0's uses 0 as the 2nd argument, not the 3rd
#4: FILE: test42.c:4:
+memset(a, b, 0);

total: 3 errors, 0 warnings, 6 lines checked

NOTE: Used message types: MEMSET

test42.c has style problems, please review.

If any of these errors are false positives, please report
them to the maintainer, see CHECKPATCH in MAINTAINERS.
--------------cut

Regards,
Mateusz
