From: Rick Jones <rick.jones2@hp.com>
Subject: Re: How I can reset TCP sockets after long suspend/resume cyscle
Date: Wed, 04 Jun 2008 14:02:36 -0700
Message-ID: <484702EC.30209@hp.com>
References: <200806011515.14103.maximlevitsky@gmail.com>	<4846B5F2.8090805@gmail.com>	<396556a20806040909q7e5eb8abi7cbc8b5ed11ed54e@mail.gmail.com> <20080604092154.7511c9d3@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adam Langley <agl@imperialviolet.org>,
	Maxim Levitsky <maximlevitsky@gmail.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:16512 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792AbYFDVCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 17:02:39 -0400
In-Reply-To: <20080604092154.7511c9d3@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While I know of at least one OS/stack which allows a root user to issue 
a command to abort a TCP connection, (and it may be two given their 
shared history) its use was always strongly discouraged.

> TCP should recover from this anyway. As soon as any activity happens
> on the connection the other end will respond with reset.  For an IMAP
> session doing the next get-mail should cause a connection reset.
> Now it is possible that mail client has other problems.

And one way for there to be activity would be for the application(s) in 
question to have an application-layer keepalive mechanism, or at the 
very least, set SO_KEEPALIVE on their connections.  And if they don't 
want to rely on the sysadmin to have set what they consider a 
"reasonable" value for when to start sending keepalive probes, a 
TCP_KEEPIDLE setsockopt() perhaps.

rick jones
