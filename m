From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] Extend netlink error codes
Date: Sat, 11 Sep 2004 17:49:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040911154914.GB21181@postel.suug.ch>
References: <20040910225158.GO20088@postel.suug.ch> <20040910160736.309bc29c.davem@davemloft.net> <1094866738.1042.53.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1094866738.1042.53.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1094866738.1042.53.camel@jzny.localdomain> 2004-09-10 21:38
> I think its a good idea.
> 
> so, questions:
> classical ABI issues
> a) old kernel vs new app
> b) new kernel vs old app

> and lastly:
> c) how to make sure no conflicts ever with updates to errno.h in the
> case of b)

Outdated error string table should result in a unknown error like
in strerror. 2^16 errno codes should be sufficient forever.

The only problem to be solved I see is where to specify the error
codes or how to distribute them between netlink users in kernel
context. Manage them as 512 blocks of 64 error codes and hand
them out to netlink users?

> one solution is to introduce a new flag NLM_F_NERR that signals kernel
> that we have a new app.

Another solution would be to add a new TLV to the ACK holding the
additional error code. However, I do like your idea better as it's
less work and easier for the userspace application.

Both, a) and b) are not problem in my eyes and can be easily solved:
  a) the user space application has to set NLM_F_ERR on all outgoing
     messages and check for the flag again in the NLMSG_ERROR handler and
     handle nlmsgerr::error differently.
  b) check nlh->nlmsg_flags & NLM_F_ERR in netlink_ack, 1-line change
