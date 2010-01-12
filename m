From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 2/3] Security: Implement disablenetwork semantics. (v4)
Date: Mon, 11 Jan 2010 20:01:17 -0800
Message-ID: <4B4BF40D.4030407@schaufler-ca.com>
References: <20100110215848.GA26609@elf.ucw.cz> <20100110224010.GA3825@heat> <201001111007.EAG82373.VHFQSLFOFMOOJt@I-love.SAKURA.ne.jp>            <4B4A8309.9090801@schaufler-ca.com> <6161.1263266388@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	michael@laptop.org, pavel@ucw.cz, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	andi@firstfloor.org, david@lang.hm, socketcan@hartkopp.net,
	alan@lxorguk.ukuu.org.uk, herbert@gondor.apana.org.au,
	bdonlan@gmail.com, zbr@ioremap.net, cscott@cscott.net,
	jmorris@namei.org, ebiederm@xmission.com, bernie@codewiz.org,
	mrs@mythic-beasts.com, randy.dunlap@oracle.com,
	xiyou.wangcong@gmail.com, sam@synack.fr, serue@us.ibm.com,
	viro@ZenIV.linux.org.uk, Casey Schaufler <casey@schaufler-ca.com>
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp102.prem.mail.sp1.yahoo.com ([98.136.44.57]:20651 "HELO
	smtp102.prem.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753783Ab0ALEBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 23:01:19 -0500
In-Reply-To: <6161.1263266388@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Valdis.Kletnieks@vt.edu wrote:
> On Sun, 10 Jan 2010 17:46:49 PST, Casey Schaufler said:
>   
>> It's much worse than that. A user that has been network disabled
>> who tries using ls may find that it goes looking for the network
>> on each name lookup and has to wait for a timeout for each.
>>     
>
> Ya know Casey - I learned back in 1986 or so that if you set up a SunOS 3.2
> cluster using Yellow Pages, professors who managed to unplug the AUI cable
> on the back of their Sun 3/50 would notice things blowing chunks.  I have to
> admit that 24 years ago I told them "Well don't do that then", and I have
> to say the same thing for anybody running a login shell network-disabled.
>
> Now, a more subtle point is that a *program* may call getuserbyname() or
> getuserbyuid() and be surprised when it times out - but that's a
> different issue than a network-deprived user calling /bin/ls.
>   

I was working at Sun when YP was introduced and was probably the
first person who had to explain what would happen if the network
got disconnected to "security experts". They weren't real happy
then, and shouldn't be happier now. If anything, today's computer
users are less well adapted to dealing with applications that
behave differently when the network is unexpectedly absent because
both the user and the programmer assume that the network will be
there because it always is. They would never set up a situation
where the network would be missing and the programs they use/write
are unlikely to handle the situation. Lazy kids.

>>          Then, if there are local file entries that differ
>> from the "official" network account values when the library
>> functions finally fall back on the local values you get the wrong
>> names for file owners.
>>     
>
> The sysadmin who set that up already had the bullet in the chamber and
> the gun pointed at their feet.  This is another "we knew better a quarter
> century ago" issue - SunOS allowed '+:' at the end of /etc/passwd to merge
> in the YP database, and Sun actively discouraged the sort of "local userid
> overlaps the YP userid space" misconfiguration you mention.
>
>   

Sysadmins are so busy fixing Sanborn-Oxley compliance issues (funded)
that they are perfectly happy to put loaded guns in their pants as far
as (unfunded) "real" security is concerned. Sure we knew better. We
knew how to do lots of things back then that the Linux community is
relearning today. Knowing better isn't going to help the current
generation, as wisdom (like you and I have) can only be passed along
by experience and exposure to the wise. I like secure systems myself,
but I certainly understand why so many people don't.

