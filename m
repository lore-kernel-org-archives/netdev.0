From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 2/3] Security: Implement disablenetwork semantics. (v4)
Date: Sun, 10 Jan 2010 17:46:49 -0800
Message-ID: <4B4A8309.9090801@schaufler-ca.com>
References: <20100110215848.GA26609@elf.ucw.cz>	<20100110224010.GA3825@heat> <201001111007.EAG82373.VHFQSLFOFMOOJt@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: michael@laptop.org, pavel@ucw.cz, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	andi@firstfloor.org, david@lang.hm, socketcan@hartkopp.net,
	alan@lxorguk.ukuu.org.uk, herbert@gondor.apana.org.au,
	Valdis.Kletnieks@vt.edu, bdonlan@gmail.com, zbr@ioremap.net,
	cscott@cscott.net, jmorris@namei.org, ebiederm@xmission.com,
	bernie@codewiz.org, mrs@mythic-beasts.com, randy.dunlap@oracle.com,
	xiyou.wangcong@gmail.com, sam@synack.fr, serue@us.ibm.com,
	viro@ZenIV.linux.org.uk, Casey Schaufler <casey@schaufler-ca.com>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201001111007.EAG82373.VHFQSLFOFMOOJt@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa wrote:
> Michael Stone wrote:
>   
>> Examples of software that I want to be able to gain privileges normally include:
>>
>>    rainbow, which requires privilege in order to add new accounts to the system
>>    and in order to call setuid() but which does not require networking
>>    privileges.
>>     
>
> If the system is not using local files (i.e. /etc/passwd and /etc/shadow),
> the process who wants to add new accounts to the system might need network
> access (e.g. to LDAP server), doesn't it?
>
>   

It's much worse than that. A user that has been network disabled
who tries using ls may find that it goes looking for the network
on each name lookup and has to wait for a timeout for each. Yet
another example of why Real Users hate security features with
such passion. Then, if there are local file entries that differ
from the "official" network account values when the library
functions finally fall back on the local values you get the wrong
names for file owners. Now we've made ls slow and untrustworthy
in the name of security.


