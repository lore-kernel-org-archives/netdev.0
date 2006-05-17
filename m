From: Benjamin Reed <br33d@yahoo.com>
Subject: Re: send(), sendmsg(), sendto() not thread-safe
Date: Wed, 17 May 2006 12:06:37 -0700 (PDT)
Message-ID: <20060517190637.98332.qmail@web51502.mail.yahoo.com>
References: <446B70F9.80707@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Christopher Friesen <cfriesen@nortel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web51502.mail.yahoo.com ([206.190.38.194]:23902 "HELO
	web51502.mail.yahoo.com") by vger.kernel.org with SMTP
	id S1750980AbWEQTGj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 May 2006 15:06:39 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <446B70F9.80707@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These discussions degrade quickly.

I'm not proposing using pread() on a socket. I was
pointing out that you can do two concurrent pread()
invocations on the same file descriptor (for a file)
and get consistent results. It would be nice if you
can do two concurrent sendmsg() invocations on the
same socket descriptor and get consistent results.

pread() does not need to be in a critical section to
work properly. sendmsg() does in general. Usually, the
fact that it needs to be in a critical section would
suggest that it is not thread safe.

ben

--- Rick Jones <rick.jones2@hp.com> wrote:

> Benjamin Reed wrote:
> > In the case of lseek() and read(), you can use
> > pread(). 
> 
> What is the meaning of the offset parameter of
> pread() for TCP or UDP etc?
> 
> rick jones
> 

