From: Benjamin Reed <br33d@yahoo.com>
Subject: Re: send(), sendmsg(), sendto() not thread-safe
Date: Wed, 17 May 2006 11:21:11 -0700 (PDT)
Message-ID: <20060517182111.42939.qmail@web51510.mail.yahoo.com>
References: <446B64D4.6080301@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web51510.mail.yahoo.com ([206.190.38.202]:60773 "HELO
	web51510.mail.yahoo.com") by vger.kernel.org with SMTP
	id S1750833AbWEQSVM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 May 2006 14:21:12 -0400
To: Christopher Friesen <cfriesen@nortel.com>
In-Reply-To: <446B64D4.6080301@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You are using the wrong examples, which may be why you
don't understand the problem Mark identified.

--- Christopher Friesen <cfriesen@nortel.com> wrote:
> There have always been possible issues with
> concurrent access to 
> sockets/fds.
> <snip>
> Or consider calling lseek() from one task, while
> doing successive read() 
> calls in the other.

I think all but the most clueless programmer would
know that lseek() and read() need to be in a critical
section. That is not the point. We are not talking
about thread-safe across calls. We are talking about
thread-safety for a given call.

In the case of lseek() and read(), you can use
pread(). pread() is cool because you don't need to
protect it with a critical section. Two threads can do
a pread() to different offsets on the same file
handle. If you protect the pread() with a critical
section, you are just wasting code, which is sloppy.
When reading the doc for sendmsg, it appears you can
avoid the critical section for sendmsg as well, but as
Mark points out, you need the critical section unless
you are running on Windows.

ben 
