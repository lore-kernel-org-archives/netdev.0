From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Netfilter Kconfig:  Expose IPv4/6 connection tracking
 options by selecting NF_CONNTRACK
Date: Tue, 24 Jul 2007 21:17:53 +0200
Message-ID: <46A65061.8010000@trash.net>
References: <200707240836.33494.a1426z@gawab.com> <200707242031.58910.a1426z@gawab.com> <46A6387D.1030601@trash.net> <200707242205.07545.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Sam Ravnborg <sam@ravnborg.org>, netdev@vger.kernel.org,
	linux-net@vger.kernel.org, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Al Boldi <a1426z@gawab.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <200707242205.07545.a1426z@gawab.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Boldi wrote:
> Patrick McHardy wrote:
> 
>>Al Boldi wrote:
>>
>>>Patrick McHardy wrote:
>>>
>>>>But I vaguely recall having tried this myself and it broke somewhere,
>>>>maybe it was because of the NF_CONNTRACK_ENABLED option, I can't
>>>>recall anymore. Al, if this also works without removal of
>>>>NF_CONNTRACK_ENABLED, please resend without that part.
>>>
>>>It doesn't.  But how about this, if you really can't live without
>>>NF_CONNTRACK_ENBLED:
>>>
>>>==================
>>>--- Kconfig.old	2007-07-09 06:38:52.000000000 +0300
>>>+++ Kconfig	2007-07-24 20:24:27.000000000 +0300
>>>@@ -25,8 +25,7 @@ config NETFILTER_NETLINK_LOG
>>> 	  and is also scheduled to replace the old syslog-based ipt_LOG
>>> 	  and ip6t_LOG modules.
>>>
>>>-# Rename this to NF_CONNTRACK in a 2.6.25
>>>-config NF_CONNTRACK_ENABLED
>>>+config NF_CONNTRACK
>>> 	tristate "Netfilter connection tracking support"
>>> 	help
>>> 	  Connection tracking keeps a record of what packets have passed
>>>@@ -40,9 +39,9 @@ config NF_CONNTRACK_ENABLED
>>>
>>> 	  To compile it as a module, choose M here.  If unsure, say N.
>>>
>>>-config NF_CONNTRACK
>>>+config NF_CONNTRACK_ENABLED
>>> 	tristate
>>>-	default NF_CONNTRACK_ENABLED
>>>+	default NF_CONNTRACK
>>>
>>> config NF_CT_ACCT
>>> 	bool "Connection tracking flow accounting"
>>
>>That defeats the only purpose why we kept it.
> 
> 
> I'm not sure how this would defeat the only purpose.  Isn't the purpose of 
> this to alias NF_CONNTRACK_ENABLED to NF_CONNTRACK?  And as such would yield 
> the same result.


The purpose is to avoid forcing people a second time to reconfigure
the conntrack options since we've completed nf_conntrack and removed
ip_conntrack. Previously NF_CONNTRACK was a bool (selecting the new
implementation) and NF_CONNTRACK_ENABLED specified whether to build
either nf_conntrack or ip_conntrack modular/static/not at all. So
old configs only have the information whether to build modular in
NF_CONNTRACK_ENABLED, but NF_CONNTRACK is what actually controls it.
With your change, old configs will still build nf_conntrack properly,
but they will always choose static linking.

> Also, we could leave this as is, and select NF_CONNTRACK_ENABLED instead of 
> NF_CONNTRACK.

I guess so, and that would have to select NF_CONNTRACK.

