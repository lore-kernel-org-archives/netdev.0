From: "Jan Beulich" <JBeulich@novell.com>
Subject: Re: [PATCH] bridge: Module use count must be updated as
	 bridges are created/destroyed
Date: Fri, 29 Apr 2011 10:09:37 +0100
Message-ID: <4DBA9C71020000780003EDBE@vpn.id2.novell.com>
References: <4DBA87B6020000780003ED74@vpn.id2.novell.com>
 <20110429.011051.183061494.davem@davemloft.net>
 <4DBA937F020000780003ED96@vpn.id2.novell.com>
 <20110429.014445.39196872.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <shemminger@linux-foundation.org>,
	<bridge@lists.linux-foundation.org>, <jeffm@suse.com>,
	<netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>,
	"Michal Marek" <mmarek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20110429.014445.39196872.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 29.04.11 at 10:44, David Miller <davem@davemloft.net> wrote:
> From: "Jan Beulich" <JBeulich@novell.com>
> Date: Fri, 29 Apr 2011 09:31:27 +0100
> 
>>>>> On 29.04.11 at 10:10, David Miller <davem@davemloft.net> wrote:
>>> From: "Jan Beulich" <JBeulich@novell.com>
>>> Date: Fri, 29 Apr 2011 08:41:10 +0100
>>> 
>>>> You talk of rmmod on the very module, but the issue is about
>>>> modprobe -r on a dependent module. I cannot believe you consider
>>>> it correct that *implicit* unloading of bridge.ko should happen when
>>>> bridges are configured.
>>> 
>>> Which module in particular depends upon bridge and causes the
>>> problem?
>> 
>> The problem was observed (a long time ago) with ebtable_broute,
>> and I cannot see how this would have changed meanwhile.
> 
> Well your change makes it so that someone who actually _wants_ to
> unload the bridge module, regardless of configuration, cannot do so.
> 
> I think that's a worse problem than this ebtables thing.
> 
> Nothing on the system should be hitting modules with unload requests
> unless the user explicitly asked for that specific module to be
> unloaded.  At least not by default.
> 
> So the me the problem is perhaps that "modprobe -r" does this auto
> dependency unloading thing by default.
> 
> When we first fixed network device drivers so that they now properly
> always run with no module refcount at all, people complained because
> there were some distributions that ran some daemon that periodically
> looked for "unreferenced" modules and "helped" the user by
> automatically unloaded them.
> 
> We killed that foolish daemon, and we can fix "modprobe -r" too.

Michal - aren't you the modutils maintainer? What are your thoughts
here? (The original report we got is
https://bugzilla.novell.com/show_bug.cgi?id=267651.)

> Does "rmmod" have this behavior too?  If not, and it does the right
> thing by only unloaded what the user asked for, then people should
> use that.

No, it doesn't. Other than modprobe, rmmod deals only with the
module specified.

> I really don't in any way want to block people from being able to
> cleanly unload the bridge module, regardless of configuration, if
> that's what they want so your patch as written is not going to be
> considered for inclusion.

I understood that meanwhile, yet fail to see an alternative solution
(imo this auto-unloading is quite desirable in other cases).

Jan

