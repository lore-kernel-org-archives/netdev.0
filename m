From: Patrick McHardy <kaber@trash.net>
Subject: Re: patch: Action repeat
Date: Sun, 01 May 2005 02:06:12 +0200
Message-ID: <42741D74.2070400@trash.net>
References: <1114879817.8929.117.camel@localhost.localdomain>	 <4273BB30.1050402@trash.net>  <4273BBAA.6060405@trash.net>	 <1114882045.8929.123.camel@localhost.localdomain>	 <4273CAB7.6080403@trash.net> <1114890709.8929.147.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1114890709.8929.147.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> You mean not passing it back via skbs but through something else?
> What do you have in mind?
> It does sound distasteful for either changing the ->act()
> parametrization just so we can have a classid passed back or provide a
> spot for it in struct tc_action since only some actions will need to
> change it. 

I meant changing ->act() to have the same prototype as tcf_act_exec()
itself:

-       int     (*act)(struct sk_buff **, struct tc_action *);
+       int     (*act)(struct sk_buff **, struct tc_action *, struct 
tcf_result *);

> I see the issue with classid leaking - perhaps specific actions could
> reset it when they steal packets? We should also reset it if the packet
> is stolen.

Since its already reset after actions are executed, we only need to
additionally reset it for packets that take a different path.
At the moment I think this only happens with mirred.

Regards
Patrick
