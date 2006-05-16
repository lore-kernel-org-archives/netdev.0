From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Setting TCP_NODELAY doesn't disable Nagle's alg. on loopback
Date: Tue, 16 May 2006 09:16:06 -0700
Message-ID: <20060516091606.39d0ecc3@localhost.localdomain>
References: <fc1d209cf91d41b5a5ff491732e52283@pobox.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:14010 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751851AbWEPQQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 May 2006 12:16:36 -0400
To: "Radko Mihal" <rmihal@pobox.sk>
In-Reply-To: <fc1d209cf91d41b5a5ff491732e52283@pobox.sk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 16 May 2006 10:50:30 +0200
"Radko Mihal" <rmihal@pobox.sk> wrote:

> Hi,
> 
> We are facing strange problem with disabling the Nagle's algorithm via setting the TCP_NODELAY flag on server socket (setsockopt), where server is communication with client via loopback.
> After the first segment (of the response) is sent by server side, server is waiting for ACK instead of continuing sending next segments (as it should use sliding window principle). The client sends ACK after 40 ms, only then server sends the rest of responses packed into one segment. The 40 ms is a big delay and causes reponse processing to be 10 times slower.
> 
> The thing doesn't happen, if we move client to another host. In that case the server don't wait for ACK, don't pack responses and also response processing is much faster.
> 
> It seems, like on loopback the Nagle's alg. is still acting (citate from alg. description says:"a first segment is sent immediately, while further data on the sender side is buffered until either a full maximum segment can be sent or an acknowledgement for the first segment is received)
> 
> I found some descriptions of the same problem, but with no solution!
> Is there a bug in setsockopt()? We are using 2.6.5 kernel.

If it is 2.6.5 that is over 2+ years old. Please try with something past the Pleistocene era...

More likely, you mean 2.6.15 and you are seeing the effect of TCP ABC.  ABC is appropriate byte count
and it penalizes applications that do small sends. The correct fix is to change your application
to use TCP_CORK or do consolidation with writev(), sendmsg(), etc. This came up with the Java
debugger, see mailing list archives.
