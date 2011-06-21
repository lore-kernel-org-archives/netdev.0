From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH]: Add Network Sysrq Support
Date: Tue, 21 Jun 2011 13:09:29 -0700
Message-ID: <20110621130929.ddd107f7.rdunlap@xenotime.net>
References: <20110621130040.12035.62533.sendpatchset@prarit.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, agospoda@redhat.com,
	nhorman@redhat.com, lwoodman@redhat.com
To: Prarit Bhargava <prarit@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy5-pub.bluehost.com ([67.222.38.55]:45799 "HELO
	oproxy5-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756665Ab1FUUJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 16:09:32 -0400
In-Reply-To: <20110621130040.12035.62533.sendpatchset@prarit.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Jun 2011 09:00:40 -0400 Prarit Bhargava wrote:

> Add Network Sysrq Support

> Signed-off-by: Prarit Bhargava <prarit@redhat.com>
> 
> diff --git a/Documentation/networking/sysrq-ping.txt b/Documentation/networking/sysrq-ping.txt
> new file mode 100644
> index 0000000..efa8be3
> --- /dev/null
> +++ b/Documentation/networking/sysrq-ping.txt
> @@ -0,0 +1,26 @@
> +In some circumstances, a system can hang/lockup in such a way that the system
> +is completely unresponsive to keyboard or console input but is still
> +responsive to ping.  The config option, CONFIG_SYSRQ_PING, builds
> +net/ipv4/sysrq-ping.ko which allows a root user to configure the system for a

or it can be built-in the kernel image... (i.e., not a loadable module)

> +remote sysrq.
> +
> +To use this do:
> +
> +mount -t debugfs none /sys/kernel/debug/
> +echo 1 > /proc/sys/kernel/sysrq
> +echo <hex digit val> > /sys/kernel/debug/network_sysrq_magic
> +echo 1 > /sys/kernel/debug/network_sysrq_enable

so all of this (insecure) stuff has to be done before you suspect that
you need it .. in case the local keyboard/console is dead.

> +
> +Then on another system you can do:
> +
> +ping -c 1 -p <hex digit val><hex val of sysrq> <target_system_name>

What are the <up to 30 hex digits> for?

> +
> +ex) sysrq-m, m is ascii 0x6d

e.g., sysrq-m (m is ASCII 0x6d)

> +
> +    ping -c 1 p 1623a06f554d46d676d <target_system_name>
> +
> +Note that the network sysrq automatically disables after the receipt of
> +the ping, ie) it is single-shot mode.  If you want to use this again, you

             i.e., it is single-shot mode.

> +must complete the above four steps again.
> +
> +Hint: 'man ascii' ;)
> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> index cbb505b..03bb7b1 100644
> --- a/net/ipv4/Kconfig
> +++ b/net/ipv4/Kconfig
> @@ -624,3 +624,11 @@ config TCP_MD5SIG
>  	  on the Internet.
>  
>  	  If unsure, say N.
> +
> +config SYSRQ_PING
> +	tristate

Needs a prompt?

> +	default m

Please do not enable random code to be built.

> +	help
> +	  Allows execution of sysrq-X commands via ping over ipv4.  This is a

No ipv6 support?  future?

> +	  known security hazard and should not be used in unsecure

	                                                  insecure

> +	  environments.


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
