From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] Extend netlink error codes
Date: 10 Sep 2004 21:38:59 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1094866738.1042.53.camel@jzny.localdomain>
References: <20040910225158.GO20088@postel.suug.ch>
	 <20040910160736.309bc29c.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040910160736.309bc29c.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-09-10 at 19:07, David S. Miller wrote:
> On Sat, 11 Sep 2004 00:51:58 +0200
> Thomas Graf <tgraf@suug.ch> wrote:
> 
> > Once in netlink_ack, split the combined error message again,
> > fill the existing errno into nlerrmsg.error and provide the
> > netlink specific error code in a newly introduced TLV. This
> > way, no binaries or old applications would break, but
> > applications can support it and provide more meanigful error
> > message with almost no effort.
> 
> It sounds like it could work.
> 
> Jamal, any objections to his idea?

I think its a good idea.

so, questions:
classical ABI issues
a) old kernel vs new app
b) new kernel vs old app

i.e:
The use of existing error codes is still valuable. Existing apps will
do:
errno = msg->error
perror("some message");

and lastly:
c) how to make sure no conflicts ever with updates to errno.h in the
case of b)

one solution is to introduce a new flag NLM_F_NERR that signals kernel
that we have a new app. In such a case, a newer kernel gives a more
precise error code and sets that same flag; old kernels ignore such a
flag - and by not setting it newer apps understand to use old errno
scheme. In this case old apps should ignore the flag.

All this is assuming that previously unused flags followed principle of 
"Must be Zero on sending and ignore when receiving" principle for
reserved bits ;-> or as otherwise known as Postels rule these days "Be
liberal in what you accept and conservative in what you send"[1]

cheers,
jamal
 
[1] Jon Postel, RFC 1122
