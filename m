From: Crispin Cowan <crispin@crispincowan.com>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Sun, 13 Apr 2008 18:41:19 -0700
Message-ID: <4802B63F.2010804@crispincowan.com>
References: <20080404122242.867070732@I-love.SAKURA.ne.jp> <20080404122408.986477936@I-love.SAKURA.ne.jp> <200804071140.59247.paul.moore@hp.com> <47FC8052.9070409@nttdata.co.jp> <20080409131151.GK11962@parisc-linux.org> <200804112312.HGE69734.LFOOHQOSFFMJtV@I-love.SAKURA.ne.jp> <20080411143013.GB11962@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	paul.moore@hp.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, takedakn@nttdata.co.jp,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080411143013.GB11962@parisc-linux.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> On Fri, Apr 11, 2008 at 11:12:27PM +0900, Tetsuo Handa wrote:
>   
>> If write access is denied because of a rule "No modifications to /etc/passwd",
>> a rule "Allow modifications to /tmp/passwd" can no longer be enforced after
>> "mount --bind /etc/ /tmp/" or "mount --bind /etc/passwd /tmp/passwd" or
>> "mv /etc/passwd /tmp/passwd" or "ln /etc/passwd /tmp/passwd" is done.
>>     
> That's a fundamental limitation of pathname-based security though.
> If the same file exists in two places, you have to resolve the question
> of which rule overrides the other.
>
> In my role as a sysadmin, I would consider it a flaw if someone could
> edit a file I'd marked uneditable -- simply by creating a hard-link to it.
> If we look at existing systems, such as the immutable bit, those apply to
> inodes, not to paths, so they can't be evaded.  If a system such as TOMOYA
> allows evasion this easily, then it doesn't seem like an improvement.
>   
You are discussing a straw-man, because AppArmor (and I think TOMOYO) do 
not operate that way.

It is not, and never has been, "mark /etc/passwd not writable". Please 
delete this broken concept from the discussion.

Rather, it is "can write to /tmp/ntpd/*". You *grant* permissions. You 
do *not* throw deny rules.

So if you grant write access to /tmp/mumble/barf you should expect it to 
always be accessible, regardless of whether someone creates an alias for it.

Please re-consider the rest of your analysis, because it doesn't work if 
there are only "allow" rules and no "deny" rules. You are correct that a 
pathname-based deny rule is trivially bypassable, that's why there 
aren't any :)

Crispin

-- 
Crispin Cowan, Ph.D.               http://crispincowan.com/~crispin
Botnets are the only commercially viable utility computing market

