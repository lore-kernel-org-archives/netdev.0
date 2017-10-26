From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv5 iproute2 net-next 2/2] lib/libnetlink: re malloc buff
 if size is not enough
Date: Thu, 26 Oct 2017 12:24:42 +0200
Message-ID: <20171026122442.7e2ac2d0@shemminger-XPS-13-9360>
References: <1508982107-28474-1-git-send-email-liuhangbin@gmail.com>
        <1508982107-28474-2-git-send-email-liuhangbin@gmail.com>
        <10ef7665-b47a-881a-ab00-1e2c6c224d0b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org,
        Michal Kubecek <mkubecek@suse.cz>, Phil Sutter <phil@nwl.cc>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:50936 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751749AbdJZKY7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 06:24:59 -0400
Received: by mail-wr0-f193.google.com with SMTP id p96so2647133wrb.7
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 03:24:58 -0700 (PDT)
In-Reply-To: <10ef7665-b47a-881a-ab00-1e2c6c224d0b@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Oct 2017 20:59:01 -0600
David Ahern <dsahern@gmail.com> wrote:

> On 10/25/17 7:41 PM, Hangbin Liu wrote:
> > +static int rtnl_recvmsg(int fd, struct msghdr *msg, char **answer)
> > +{
> > +	struct iovec *iov = msg->msg_iov;
> > +	char *buf;
> > +	int len;
> > +
> > +	iov->iov_base = NULL;
> > +	iov->iov_len = 0;
> > +
> > +	len = __rtnl_recvmsg(fd, msg, MSG_PEEK | MSG_TRUNC);
> > +	if (len < 0)
> > +		return len;
> > +
> > +	buf = malloc(len);
> > +	if (!buf) {
> > +		fprintf(stderr, "malloc error: not enough buffer\n");
> > +		return -ENOMEM;
> > +	}
> > +
> > +	iov->iov_base = buf;
> > +	iov->iov_len = len;
> > +
> > +	len = __rtnl_recvmsg(fd, msg, 0);
> > +	if (len < 0) {
> > +		free(buf);
> > +		return len;
> > +	}  
> 
> The kernel needs a flag that says "give me the message of the buffer is
> large enough; if not just PEEK and tell me the length." That would avoid
> the double call in most cases.

Actually this has little impact because old code was doing implicit zero
of whole buffer, new code does not.
