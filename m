From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: RE: [PATCH] rds: Error on offset mismatch if not loopback
Date: Wed, 13 Nov 2013 07:16:10 -0800 (PST)
Message-ID: <23964ca1-e7cb-41c3-9da2-5bc1b2b0c014@default>
References: <20120921213239.GJ14393@linux-tkdk.sfcn.org>
 <20120922.152524.1294103117346567757.davem@davemloft.net>
 <CAKA=qzac9=UhLF_Z4FnnH+sR7xvkDux4oayC6dPYe=hMLsDxRg@mail.gmail.com>
 <CAKA=qzYpd7Wo9XdU16TEhnbm5dPJjOZMhAY1jA7N+YFBWz5pzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: jjolly@suse.com, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Josh Hunt <joshhunt00@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30724 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755347Ab3KMPQQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 10:16:16 -0500
In-Reply-To: <CAKA=qzYpd7Wo9XdU16TEhnbm5dPJjOZMhAY1jA7N+YFBWz5pzw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-----Original Message-----
From: Josh Hunt [mailto:joshhunt00@gmail.com] 
Sent: Tuesday, November 12, 2013 10:25 PM
To: David Miller
Cc: jjolly@suse.com; LKML; Venkat Venkatsubra; netdev@vger.kernel.org
Subject: Re: [PATCH] rds: Error on offset mismatch if not loopback

On Tue, Nov 12, 2013 at 10:22 PM, Josh Hunt <joshhunt00@gmail.com> wrote:
> On Sat, Sep 22, 2012 at 2:25 PM, David Miller <davem@davemloft.net> wrote:
>>
>> From: John Jolly <jjolly@suse.com>
>> Date: Fri, 21 Sep 2012 15:32:40 -0600
>>
>> > Attempting an rds connection from the IP address of an IPoIB 
>> > interface to itself causes a kernel panic due to a BUG_ON() being triggered.
>> > Making the test less strict allows rds-ping to work without 
>> > crashing the machine.
>> >
>> > A local unprivileged user could use this flaw to crash the system.
>> >
>> > Signed-off-by: John Jolly <jjolly@suse.com>
>>
>> Besides the questions being asked of you by Venkat Venkatsubra, this 
>> patch has another issue.
>>
>> It has been completely corrupted by your email client, it has turned 
>> all TAB characters into spaces, making the patch useless.
>>
>> Please learn how to send a patch unmolested in the body of your 
>> email.  Test it by emailing the patch to yourself, and verifying that 
>> you can in fact apply the patch you receive in that email.
>> Then, and only then, should you consider making a new submission of 
>> this patch.
>>
>> Use Documentation/email-clients.txt for guidance.
>> --
>> To unsubscribe from this list: send the line "unsubscribe 
>> linux-kernel" in the body of a message to majordomo@vger.kernel.org 
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>
>
> I think this issue was lost in the shuffle. It appears that redhat, 
> ubuntu, and oracle are maintaining local patches to resolve this:
>
> https://oss.oracle.com/git/?p=redpatch.git;a=commit;h=c7b6a0a1d8d63685
> 2be130fa15fa8be10d4704e8
> https://bugzilla.redhat.com/show_bug.cgi?id=822754
> http://ubuntu.5.x6.nabble.com/CVE-2012-2372-RDS-local-ping-DOS-td49853
> 88.html
>
> Given that Oracle has applied it I'll make the assumption that 
> Venkat's question was answered at some point.
>
> David - I can resubmit the patch with the proper signed-off-by and 
> formatting if you are willing to apply it unless John wants to try 
> again. I think it's time this got upstream.
>
> --
> Josh

Ugh.. hopefully resending with all the html crap removed...

--
Josh

Hi Josh,

No, I still didn't get an answer for how "off" could be non-zero in case of rds-ping to hit BUG_ON(off % RDS_FRAG_SIZE).
Because, rds-ping uses zero byte messages to ping.
If you have a test case that reproduces the kernel panic I can try it out and see how that can happen.
The Oracle's internal code I checked doesn't have that patch applied.

Venkat
