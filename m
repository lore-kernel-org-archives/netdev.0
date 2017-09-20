From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv3 iproute2 1/2] lib/libnetlink: re malloc buff if size
 is not enough
Date: Wed, 20 Sep 2017 09:56:05 -0700
Message-ID: <20170920095605.1ea527fc@xeon-e3>
References: <1505871820-31580-1-git-send-email-liuhangbin@gmail.com>
        <1505871820-31580-2-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michal Kubecek <mkubecek@suse.cz>,
        Phil Sutter <phil@nwl.cc>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:48510 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751693AbdITQ4J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 12:56:09 -0400
Received: by mail-pg0-f48.google.com with SMTP id v23so2004003pgc.5
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 09:56:09 -0700 (PDT)
In-Reply-To: <1505871820-31580-2-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Sep 2017 09:43:39 +0800
Hangbin Liu <liuhangbin@gmail.com> wrote:

Thanks for keeping up on this.


> +realloc:
> +	bufp = realloc(buf, buf_len);
> +
> +	if (bufp == NULL) {

Minor personal style issue:
To me, blank lines are like paragraphs in writing.
Code reads better assignment and condition check are next to
each other.

> +recv:
> +	len = recvmsg(fd, msg, flag);
> +
> +	if (len < 0) {
> +		if (errno == EINTR || errno == EAGAIN)
> +			goto recv;
> +		fprintf(stderr, "netlink receive error %s (%d)\n",
> +			strerror(errno), errno);
> +		free(buf);
> +		return -errno;
> +	}
> +
> +	if (len == 0) {
> +		fprintf(stderr, "EOF on netlink\n");
> +		free(buf);
> +		return -ENODATA;
> +	}
> +
> +	if (len > buf_len) {
> +		buf_len = len;
> +		flag = 0;
> +		goto realloc;
> +	}
> +
> +	if (flag != 0) {
> +		flag = 0;
> +		goto recv;

Although I programmed in BASIC years ago. I never liked code
with loops via goto. To me it indicates the logic is not well thought
through.  Not sure exactly how to rearrange the control flow, but it
should be possible to rewrite this so that it reads cleaner.

Still think this needs to go through a few more review cycles
before applying.
