From: Josh Hunt <joshhunt00@gmail.com>
Subject: Re: [PATCH] rds: Error on offset mismatch if not loopback
Date: Wed, 13 Nov 2013 11:40:45 -0600
Message-ID: <CAKA=qzbK1YX5OrVQbwM=1xM6Si=GKv0UDofULkOC7RNo08zZPw@mail.gmail.com>
References: <20120921213239.GJ14393@linux-tkdk.sfcn.org>
	<20120922.152524.1294103117346567757.davem@davemloft.net>
	<CAKA=qzac9=UhLF_Z4FnnH+sR7xvkDux4oayC6dPYe=hMLsDxRg@mail.gmail.com>
	<CAKA=qzYpd7Wo9XdU16TEhnbm5dPJjOZMhAY1jA7N+YFBWz5pzw@mail.gmail.com>
	<23964ca1-e7cb-41c3-9da2-5bc1b2b0c014@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, jjolly@suse.com,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	honli@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:57569 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756914Ab3KMRkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 12:40:46 -0500
In-Reply-To: <23964ca1-e7cb-41c3-9da2-5bc1b2b0c014@default>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 13, 2013 at 9:16 AM, Venkat Venkatsubra
<venkat.x.venkatsubra@oracle.com> wrote:
>
>
> -----Original Message-----
> From: Josh Hunt [mailto:joshhunt00@gmail.com]
> Sent: Tuesday, November 12, 2013 10:25 PM
> To: David Miller
> Cc: jjolly@suse.com; LKML; Venkat Venkatsubra; netdev@vger.kernel.org
> Subject: Re: [PATCH] rds: Error on offset mismatch if not loopback
>
> On Tue, Nov 12, 2013 at 10:22 PM, Josh Hunt <joshhunt00@gmail.com> wrote:
>> On Sat, Sep 22, 2012 at 2:25 PM, David Miller <davem@davemloft.net> wrote:
>>>
>>> From: John Jolly <jjolly@suse.com>
>>> Date: Fri, 21 Sep 2012 15:32:40 -0600
>>>
>>> > Attempting an rds connection from the IP address of an IPoIB
>>> > interface to itself causes a kernel panic due to a BUG_ON() being triggered.
>>> > Making the test less strict allows rds-ping to work without
>>> > crashing the machine.
>>> >
>>> > A local unprivileged user could use this flaw to crash the system.
>>> >
>>> > Signed-off-by: John Jolly <jjolly@suse.com>
>>>
>>> Besides the questions being asked of you by Venkat Venkatsubra, this
>>> patch has another issue.
>>>
>>> It has been completely corrupted by your email client, it has turned
>>> all TAB characters into spaces, making the patch useless.
>>>
>>> Please learn how to send a patch unmolested in the body of your
>>> email.  Test it by emailing the patch to yourself, and verifying that
>>> you can in fact apply the patch you receive in that email.
>>> Then, and only then, should you consider making a new submission of
>>> this patch.
>>>
>>> Use Documentation/email-clients.txt for guidance.
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe
>>> linux-kernel" in the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> Please read the FAQ at  http://www.tux.org/lkml/
>>
>>
>> I think this issue was lost in the shuffle. It appears that redhat,
>> ubuntu, and oracle are maintaining local patches to resolve this:
>>
>> https://oss.oracle.com/git/?p=redpatch.git;a=commit;h=c7b6a0a1d8d63685
>> 2be130fa15fa8be10d4704e8
>> https://bugzilla.redhat.com/show_bug.cgi?id=822754
>> http://ubuntu.5.x6.nabble.com/CVE-2012-2372-RDS-local-ping-DOS-td49853
>> 88.html
>>
>> Given that Oracle has applied it I'll make the assumption that
>> Venkat's question was answered at some point.
>>
>> David - I can resubmit the patch with the proper signed-off-by and
>> formatting if you are willing to apply it unless John wants to try
>> again. I think it's time this got upstream.
>>
>> --
>> Josh
>
> Ugh.. hopefully resending with all the html crap removed...
>
> --
> Josh
>
> Hi Josh,
>
> No, I still didn't get an answer for how "off" could be non-zero in case of rds-ping to hit BUG_ON(off % RDS_FRAG_SIZE).
> Because, rds-ping uses zero byte messages to ping.
> If you have a test case that reproduces the kernel panic I can try it out and see how that can happen.
> The Oracle's internal code I checked doesn't have that patch applied.
>
> Venkat

No I don't have a test case. I came across this CVE while doing an
audit and noticed it was patched in Ubuntu's kernel and other distros,
but was not in the upstream kernel yet. Quick googling of lkml showed
that there were at least two attempts to get this patch upstream, but
both had issues due to not following the proper submission process:

https://lkml.org/lkml/2012/10/22/433
https://lkml.org/lkml/2012/9/21/505

>From my searching it appears the initial bug was found by someone at redhat:
https://bugzilla.redhat.com/show_bug.cgi?id=822754

I've added Li Honggang the reporter of this issue from Redhat to the
mail. Hopefully he can share his testcase.

and possibly requires certain hardware as Jay writes in the first link above:
"...some Infiniband HCAs(QLogic, possibly others) the machine will panic..."

I was referring to this oracle commit:
https://oss.oracle.com/git/?p=redpatch.git;a=commit;h=c7b6a0a1d8d636852be130fa15fa8be10d4704e8

I have no experience with this code. There were a few comments around
the reset and xmit fns about making sure the caller did certain things
if not they were racy, but I have no idea if that's coming into play
here.

-- 
Josh
