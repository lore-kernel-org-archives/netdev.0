From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] dynamic_debug: Restore dev_dbg functionality,
 optimize stack
Date: Tue, 31 Jul 2012 14:55:34 -0700
Message-ID: <20120731145534.5606e840.akpm@linux-foundation.org>
References: <1343334310.17538.32.camel@joe2Laptop>
	<333324dcdfdc891ba214d2de8f9a3d056dd7aea9.1343461712.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Baron <jbaron@redhat.com>,
	Jim Cromie <jim.cromie@gmail.com>, Kay Sievers <kay@vrfy.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:40807 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755521Ab2GaVzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 17:55:36 -0400
In-Reply-To: <333324dcdfdc891ba214d2de8f9a3d056dd7aea9.1343461712.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 28 Jul 2012 00:55:07 -0700
Joe Perches <joe@perches.com> wrote:

> commit c4e00daaa9 ("driver-core: extend dev_printk() to pass structured data")
> changed __dev_printk and broke dynamic-debug's ability to control the
> dynamic prefix of dev_dbg(dev,..).
> 
> dynamic_emit_prefix() adds "[tid] module:func:line:" to the output and
> those additions got lost.
> 
> In addition, the current dynamic debug code uses up to 3 recursion
> levels via %pV.  This can consume quite a bit of stack.  Directly
> call printk_emit to reduce the recursion depth.
> 
> These changes include:
> 
> o Remove KERN_DEBUG from dynamic_emit_prefix
> o Create and use function create_syslog_header to format the syslog
>   header for printk_emit uses.
> o Call create_syslog_header and neaten __dev_printk
> o Call create_syslog_header and printk_emit from dynamic_dev_dbg
> o Call create_syslog_header and printk_emit from dynamic_netdev_dbg
> o Make __dev_printk and __netdev_printk static not global
> o Remove include header declarations of __dev_printk and __netdev_printk
> o Remove now unused EXPORT_SYMBOL()s of __dev_printk and __netdev_printk
> o Whitespace neatening
> 
> Changes in v2:
> 
> o Fix dynamic_emit_prefix to always initialize output
> o Call create_syslog_header and emit_printk from__netdev_printk and
>   eliminate call to dev_printk to remove another recursion via %pV

This one causes an oops-on-boot
(http://ozlabs.org/~akpm/stuff/IMG_20120731_144047.jpg).  v1 didn't do
that.

config: http://ozlabs.org/~akpm/stuff/config-akpm2
