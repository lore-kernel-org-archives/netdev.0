From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] netfilter: WIP: Xtables idletimer target implementation
Date: Mon, 31 May 2010 17:59:47 +0200
Message-ID: <4C03DCF3.1080001@trash.net>
References: <1274993689-23928-1-git-send-email-luciano.coelho@nokia.com>	 <alpine.LSU.2.01.1005280057190.14077@obet.zrqbmnf.qr>	 <1275024304.3754.45.camel@powerslave>	 <alpine.LSU.2.01.1005281001550.11570@obet.zrqbmnf.qr> <1275040724.24490.121.camel@chilepepper>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: ext Jan Engelhardt <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Timo Teras <timo.teras@iki.fi>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1275040724.24490.121.camel@chilepepper>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Luciano Coelho wrote:
> On Fri, 2010-05-28 at 10:05 +0200, ext Jan Engelhardt wrote:
>> On Friday 2010-05-28 07:25, Luciano Coelho wrote:
>>> Do you have any other suggestion on how I can associate the rules to
>>> specific interfaces?
>> -A INPUT -i foo -j do
>> -A do -j idletimer
>>
>> A little funny, but actually this would allow me to keep a timer
>> for a group of interfaces rather than just per-if.
> 
> Yes, this is what our userspace apps are doing.  I've formulated my
> question in an unclear way.  If you check the rest of the code, I create
> sysfs files under the interface's directory and use it as an attribute
> to notify the userspace when the timer has expired.
> 
> In short, I need to figure out a way to associate each rule with an
> interface in sysfs, so I can notify the userspace when the timer has
> expired.  I couldn't figure out another way to do it.  Any suggestions?

How about just using an arbitrary user-supplied name? People can
name them after interfaces, or anything else.

>>>>> +static int xt_idletimer_checkentry(const struct xt_tgchk_param *par)
>>>>> +{
>>>>> +	const struct xt_idletimer_info *info = par->targinfo;
>>>>> +	const struct ipt_entry *entryinfo = par->entryinfo;
>>>>> +	const struct ipt_ip *ip = &entryinfo->ip;
>>>> I'm not sure spying on ipt_ip is a long-term viable solution.
>>> Do you have any other suggestions on how I could get an interface
>>> associated with the rule? I thought about having the userspace pass the
>>> interface as an option to the rule (like I already do for the timeout
>>> value), but that looked ugly to me, since the interface can already be
>>> defined as part of the ruleset.
>> I have patches ready since a while that decouple ipt_ip
>> from a rule, so there is no guarantee that such will exist.
> 
> Okay, if that's the case, then I don't know how to associate the rule
> with a specific net object in the kobject tree.  Maybe I have to figure
> out a different way to notify the userspace, unless I add the target
> option I mentioned above. :/
> 
> 

