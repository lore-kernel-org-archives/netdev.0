From: "David S. Miller" <davem@redhat.com>
Subject: Re: problem setting net.ipvX.conf.all.forwarding via sysctl()
 system call
Date: Sat, 9 Aug 2003 01:06:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030809010606.6cfce75c.davem@redhat.com>
References: <20030803154427.GA12926@wsx.ksp.sk>
	<20030808.174504.14391608.yoshfuji@linux-ipv6.org>
	<20030808091124.GA17961@wsx.ksp.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jan Oravec <jan.oravec@6com.sk>
In-Reply-To: <20030808091124.GA17961@wsx.ksp.sk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 8 Aug 2003 11:11:24 +0200
Jan Oravec <jan.oravec@6com.sk> wrote:

> this is a new patch
 ...
> +	ipv4_devconf.forwarding = new;
>  	inet_forward_change();
> -	return 1;
> +	return 0;

This is still wrong.

First of all we have the table->data pointer in "valp"
so let's use that to set the value.  In this way we can
use this function for other sysctl values if we ever desire
to do that.

Second, if we set the table->data value, we must return > 0.
This tells the caller that we've done the sysctl value update.
If we return zero, it would update the value a second time.

Here is the fix I'm going to use.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1136  -> 1.1137 
#	net/ipv4/sysctl_net_ipv4.c	1.11    -> 1.12   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/09	davem@nuts.ninka.net	1.1137
# [IPV4]: Fix setting net.ipv4.conf.all.forwarding via sysctl() system call.
# --------------------------------------------
#
diff -Nru a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
--- a/net/ipv4/sysctl_net_ipv4.c	Sat Aug  9 01:02:17 2003
+++ b/net/ipv4/sysctl_net_ipv4.c	Sat Aug  9 01:02:17 2003
@@ -109,6 +109,7 @@
 		}
 	}
 
+	*valp = new;
 	inet_forward_change();
 	return 1;
 }
