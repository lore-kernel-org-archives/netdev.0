From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6 NET] Catch wrong RTATTR_MAX with BUG()
Date: Thu, 9 Sep 2004 09:55:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909095531.331fd168.davem@davemloft.net>
References: <20040909164346.GA18994@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040909164346.GA18994@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 9 Sep 2004 18:43:46 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> Catches outdated/invalid RTATTR_MAX and therefore avoids possible stack
> corruption.

Your test has an off by one error, but more importantly,
it's probably better to do this at compile time with
something like:

extern void rtattr_max_too_small(void);

...

void __init rtnetlink_init(void)
{
	if (IFLA_MAX > RTATTR_MAX ||
	    IFA_MAX > RTATTR_MAX ||
	    RTA_MAX > RTATTR_MAX ||
	    NDA_MAX > RTATTR_MAX ||
	    TCA_MAX > RTATTR_MAX ||
	    TCAA_MAX > RTATTR_MAX)
		rtattr_max_too_small();

I would therefore accept a patch that did things
this way.  BUG()'ing at runtime for something like
this is too rude. :)

Thanks.
