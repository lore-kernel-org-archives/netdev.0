From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Tue, 21 Apr 2009 16:42:28 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904211640280.31780@qirst.com>
References: <1238701718.5669.26.camel@bender>  <alpine.DEB.1.10.0904211131340.21796@qirst.com> <7e0dd21a0904211313p73143cc8t51b5c537c5edfb05@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Johann Baudy <johann.baudy@gnu-log.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:38131 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783AbZDUUuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 16:50:32 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5055682C713
	for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 17:00:52 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id C-MuLxStsinM for <netdev@vger.kernel.org>;
	Tue, 21 Apr 2009 17:00:47 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A4A9582C70F
	for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 17:00:47 -0400 (EDT)
In-Reply-To: <7e0dd21a0904211313p73143cc8t51b5c537c5edfb05@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Apr 2009, Johann Baudy wrote:

> > Also can you ensure that send() continues to send if I concurrently set
> > the status to TP_STATUS_SEND_REQUEST from another thread? How it is
> > serialized anyways? Status is an atomic value? Or do you rely on status
> > only being modified while send() is running?
>
> TP_STATUS_KERNEL => TP_STATUS_SEND_REQUEST: only performed by user.
> TP_STATUS_SEND_REQUEST => TP_STATUS_SENDING  only performed by kernel
> TP_STATUS_SENDING => TP_STATUS_KERNEL  only performed by kernel.
>
> Only one thread is allowed to change status values from user space.

Duh. So I cannot concurrently operate with multiple threads on the
structure.

The kernel synchronizes with itself via the socket?

> This way, you can take advantage of smp. One thread is filling the
> buffer changing status  from TP_STATUS_KERNEL to
> TP_STATUS_SEND_REQUEST , another is calling send() in loop
> (MSG_DONTBLOCK option can be used).

Ah ok.

