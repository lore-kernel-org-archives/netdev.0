From: Johann Baudy <johann.baudy@gnu-log.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Tue, 21 Apr 2009 23:13:22 +0200
Message-ID: <7e0dd21a0904211413g61a9132bu4beb9b4c21af341b@mail.gmail.com>
References: <1238701718.5669.26.camel@bender>
	 <alpine.DEB.1.10.0904211131340.21796@qirst.com>
	 <7e0dd21a0904211313p73143cc8t51b5c537c5edfb05@mail.gmail.com>
	 <alpine.DEB.1.10.0904211640280.31780@qirst.com>
	 <7e0dd21a0904211400l3c9e78e9v70b684702eef89d5@mail.gmail.com>
	 <alpine.DEB.1.10.0904211657500.31780@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f163.google.com ([209.85.218.163]:63598 "EHLO
	mail-bw0-f163.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758318AbZDUVNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 17:13:24 -0400
Received: by bwz7 with SMTP id 7so1991858bwz.37
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 14:13:22 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.10.0904211657500.31780@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Doesnt the kernel need some way to synchronize the two
> transitions made by the kernel? From "send request" to "sending" and then
> to "available"? Otherwise the kernel may set the request to "available"
> before the change from "send request" to "sending" is complete.

This synchronization is performed through skb mechanism.
"send request" to "sending" is done before submitting skb to device.
"sending" to "available" will be performed in skb destructor.
