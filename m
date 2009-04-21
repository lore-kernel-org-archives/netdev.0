From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Tue, 21 Apr 2009 11:36:27 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904211131340.21796@qirst.com>
References: <1238701718.5669.26.camel@bender>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Johann Baudy <johann.baudy@gnu-log.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:41818 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752306AbZDUPoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 11:44:38 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8095E82C555
	for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 11:55:01 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id rX2dZzsCgK5Q for <netdev@vger.kernel.org>;
	Tue, 21 Apr 2009 11:54:55 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8719982C50E
	for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 11:54:50 -0400 (EDT)
In-Reply-To: <1238701718.5669.26.camel@bender>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2 Apr 2009, Johann Baudy wrote:

> +++ Transmission process
> +Those defines are also used for transmission:
> +
> +     #define TP_STATUS_KERNEL        0 // Frame is available
> +     #define TP_STATUS_USER          1 // Frame will be sent on next send()
> +     #define TP_STATUS_COPY          2 // Frame is currently in transmission
> +
> +First, the kernel initializes all frames to TP_STATUS_KERNEL. To send a packet,
> +the user fills a data buffer of an available frame, sets tp_len to current
> +data buffer size and sets its status field to TP_STATUS_USER. This can be done
> +on multiple frames. Once the user is ready to transmit, it calls send().
> +Then all buffers with status equal to TP_STATUS_USER are forwarded to the
> +network device. The kernel updates each status of sent frames with
> +TP_STATUS_COPY until the end of transfer.
> +At the end of each transfer, buffer status returns to TP_STATUS_KERNEL.

Could you clean then states up a bit to reflect what they actually mean?

TP_STATUS_AVAILABLE		=> Frame is available
TP_STATUS_SEND_REQUEST		=> Frame waits for sending
TP_STATUS_SENDING		=> Frame is being sent.


Also can you ensure that send() continues to send if I concurrently set
the status to TP_STATUS_SEND_REQUEST from another thread? How it is
serialized anyways? Status is an atomic value? Or do you rely on status
only being modified while send() is running?


