From: jamal <hadi@cyberus.ca>
Subject: Re: patch: Action repeat
Date: Sat, 30 Apr 2005 15:51:49 -0400
Message-ID: <1114890709.8929.147.camel@localhost.localdomain>
References: <1114879817.8929.117.camel@localhost.localdomain>
	 <4273BB30.1050402@trash.net>  <4273BBAA.6060405@trash.net>
	 <1114882045.8929.123.camel@localhost.localdomain>
	 <4273CAB7.6080403@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4273CAB7.6080403@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-30-04 at 20:13 +0200, Patrick McHardy wrote:

> Since it only has such a short lifetime (action function sets it,
> tcf_action_exec() clears it after changing classification result),
> it would be less wasteful to just pass the classification result
> to the actions. This would also avoid that skbs with tc_classid
> already set can reach tcf_action_exec() (for example through mirred).
> 
> What do you think?

You mean not passing it back via skbs but through something else?
What do you have in mind?
It does sound distasteful for either changing the ->act()
parametrization just so we can have a classid passed back or provide a
spot for it in struct tc_action since only some actions will need to
change it. 


I see the issue with classid leaking - perhaps specific actions could
reset it when they steal packets? We should also reset it if the packet
is stolen.

cheers,
jamal

[In the long run really the classid setting should be per action
setting;
i.e when a user sets "flowid X:Y" they are explictly saying " action
metaset class X:Y";]
