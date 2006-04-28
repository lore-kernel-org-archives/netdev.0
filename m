From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 23:59:30 +0400
Message-ID: <20060428195930.GB21294@2ka.mipt.ru>
References: <20060428172932.GB16916@2ka.mipt.ru> <20060428104118.6a056a59@localhost.localdomain> <20060428175538.GA13898@2ka.mipt.ru> <20060428.121636.54294183.davem@davemloft.net> <20060428124915.686911c1@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "David S. Miller" <davem@davemloft.net>, caitlinb@broadcom.com,
	kelly@au1.ibm.com, rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:30616 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751787AbWD1UAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 16:00:33 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060428124915.686911c1@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 28, 2006 at 12:49:15PM -0700, Stephen Hemminger (shemminger@osdl.org) wrote:
> But there is this huge semantic overload of kevent, poll, epoll, aio,
> regular sendmsg/recv, posix aio, etc.  
> 
> Perhaps a clean break with the socket interface is needed. Otherwise, there
> are nasty complications with applications that mix old socket calls and new interface
> on the same connection.

kevent can be used as poll without any changes to the socket code.
There are two types of network related kevents - socket events
(recv/send/accept) and network aio, which can be turned completely off
in config.
There are following events which are supported by kevent:
o usual poll/select notifications
o inode notifications (create/remove)
o timer notifications
o socket notifications (send/recv/accept)
o network aio system
o fs aio (project closed, aio_sendfile() is being developed instead)

Any of the above can be turned off by config option.

-- 
	Evgeniy Polyakov
