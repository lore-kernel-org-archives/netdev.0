From: "Jan Beulich" <JBeulich@novell.com>
Subject: Re: [PATCH] bridge: Module use count must be updated as
	 bridges are created/destroyed
Date: Fri, 29 Apr 2011 08:41:10 +0100
Message-ID: <4DBA87B6020000780003ED74@vpn.id2.novell.com>
References: <4DBA830A020000780003ED5D@vpn.id2.novell.com>
 <20110429.002530.112581952.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <shemminger@linux-foundation.org>,
	<bridge@lists.linux-foundation.org>, <jeffm@suse.com>,
	<netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20110429.002530.112581952.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 29.04.11 at 09:25, David Miller <davem@davemloft.net> wrote:
> From: "Jan Beulich" <JBeulich@novell.com>
> Date: Fri, 29 Apr 2011 08:21:14 +0100
> 
>> Otherwise 'modprobe -r' on a module having a dependency on bridge will
>> implicitly unload bridge, bringing down all connectivity that was using
>> bridges.
>> 
>> Signed-off-by: Jan Beulich <jbeulich@novell.com>
>> Cc: Jeff Mahoney <jeffm@suse.com>
> 
> All network device drivers behave exactly the same way, when you rmmod
> the thing we unconfigure all the routes, addresses, etc. going through
> that device and let you unload it.
> 
> And this behavior is very much intentional.
> 
> Don't add an exception here.

You talk of rmmod on the very module, but the issue is about
modprobe -r on a dependent module. I cannot believe you consider
it correct that *implicit* unloading of bridge.ko should happen when
bridges are configured.

If the solution proposed isn't satisfactory, can you suggest a better
alternative still serving the purpose?

Jan

