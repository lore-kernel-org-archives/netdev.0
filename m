From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BK PATCH 2.6] fix sysctl breakage during network device
 renaming, for ipv4
Date: Wed, 27 Aug 2003 23:28:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030827232847.68cc17a6.davem@redhat.com>
References: <20030826153812.GA2216@callisto.yi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dan Aloni <da-x@gmx.net>
In-Reply-To: <20030826153812.GA2216@callisto.yi.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 26 Aug 2003 18:38:12 +0300
Dan Aloni <da-x@gmx.net> wrote:

>   Sysctl assumes its ctl_table.procname field is const, but the 
>   networking points ctl_table.procname to dev->name. When renaming 
>   a network device using SIOCSIFNAME, dev->name is modified and 
>   sysctl's assumption breaks, causing this behaviour, at least:
>   
>     1. sysctl wouldn't be able to remove the proc entry when the 
>        device requests to be unregistered, because it would be 
>        using the new name instead of the old one.
>     2. proc entries for devices remain with the old name after 
>        rename.
>     
>   This change includes allocating the current device name to a
>   new copy upon registering with sysctl, plus re-registering with 
>   sysctl when the device is renamed.

Conceptually this change is OK.  But please don't put generic
things like a strdup() implementation statically into
net/ipv4/devinet.c, it does not belong there.
