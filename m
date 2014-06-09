From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: SCTP connect() both ways
Date: Mon, 09 Jun 2014 14:40:55 -0400
Message-ID: <5395FFB7.4060604@gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1725978A@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f44.google.com ([209.85.216.44]:49113 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753704AbaFISk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 14:40:58 -0400
Received: by mail-qa0-f44.google.com with SMTP id j7so8213780qaq.31
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 11:40:57 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1725978A@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/09/2014 05:41 AM, David Laight wrote:
> When SCTP is used for protocols like M3UA it seems common
> to configure both port numbers for a connection (typically
> to the same value).
> 
> Rather than having one system call connect() and the other
> listen(), both systems really want to try to establish the
> connection by sending out INIT chunks.

The correct way to do this is to not used connect() call.
Both systems should do a listen() and then use an implicit
connect by using an sctp_sendmsg() or similar calls to
send the data.

> 
> The connection then gets established as soon as the second of the
> two systems attempts to establish it.
> 
> However if the remote system responds with an ABORT (or maybe
> an ICMP error is received) the Linux SCTP stack immediately
> reports 'connect failed'.
> For these sorts of connections it would be much better if the
> received ABORT just increased the retry timer to large value.
> 
> Thoughts?

We don't know why the remote ABORTED.  There could be a lot of
reasons.  It is up to the application to retry.  This is no
different then receiving an RST in response to a SYN.

-vlad

> 
> 	David
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
