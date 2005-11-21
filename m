From: "Christopher Friesen" <cfriesen@nortel.com>
Subject: Re: netlink nlmsg_pid supposed to be pid or tid?
Date: Mon, 21 Nov 2005 15:47:25 -0600
Message-ID: <4382406D.1040508@nortel.com>
References: <438220C3.4040602@nortel.com> <E1EeIcx-0006i3-00@gondolin.me.apana.org.au> <20051121213549.GA28187@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751073AbVKUVrh@vger.kernel.org>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20051121213549.GA28187@ms2.inr.ac.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov wrote:
> Hello!
> 
> 
>>I tend to agree with you here that tgid makes more sense.
> 
> 
> I agree, apparently netlink_autobind was missed when sed'ing pid->tgid.
> Of course, it does not matter, but tgid is nicer choice from user's viewpoint.

I'm glad you agree, but I'm not sure what you mean by "it does not matter".

TIPC wants the user to fill in the pid to use in the nlmsghdr portion of 
a particular message.

When an NPTL child thread uses getpid() to specify the pid, it never 
receives a response to this request.  Running the same code on the 
parent works, and running the same code under Linuxthreads works.

Using gettid() works, but it also means that only the thread that issued 
the request can read the reply.

Chris
