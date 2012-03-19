From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [PATCH] adjust __net_exit
Date: Mon, 19 Mar 2012 09:09:49 +0000
Message-ID: <4F6705ED0200007800079343@nat28.tlf.novell.com>
References: <4F588BEC020000780007710A@nat28.tlf.novell.com>
 <20120316.221813.236130733754848615.davem@davemloft.net>
 <20120317230318.GA19460@merkur.ravnborg.org>
 <4F66F8F70200007800079305@nat28.tlf.novell.com>
 <20120319084703.GA20897@merkur.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, <xemul@openvz.org>,
	<netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
	<ebiederm@xmission.com>
To: "Sam Ravnborg" <sam@ravnborg.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120319084703.GA20897@merkur.ravnborg.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> On 19.03.12 at 09:47, Sam Ravnborg <sam@ravnborg.org> wrote:
>> >> > Using the (bogus and unused elsewhere)
>> >> > __exit_refok to implement this is inefficient - any non-modular code
>> >> > really can reside in __init (as non-modular __exit code is never used).
> 
>> > 2) fix up the bogus commit message
>> 
>> Bogus in what way?
> 
> I fail to see that __exit_refok is bogus.

Either an exit function references only permitted code (in which case
it is legitimately using __exit), or it references non-__exit code, in
which case it shouldn't have an override at all. Permitting an exit
function to reference e.g. __init code is suspicious (at best) in all
cases I can think of (in contrast to allowing a non-init function to
reference __init code on a code path that can be proven to be taken
only during system startup).

Jan

> The name is not optimal - which is why is is deprecated.
> 
> 	Sam



