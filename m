From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] PKT_SCHED: validate policer configuration TLVs
Date: Tue, 7 Dec 2004 21:32:34 -0800
Message-ID: <20041207213234.257fd0d9.davem@davemloft.net>
References: <20041207172349.GG1371@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041207172349.GG1371@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 7 Dec 2004 18:23:49 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> Adds TLV size sanity checks for policer configuration. 

Hmmm...

> -	if (tb[TCA_POLICE_RESULT-1])
> +	if (tb[TCA_POLICE_RESULT-1]) {
> +		if (RTA_PAYLOAD(tb[TCA_POLICE_RESULT-1]) != sizeof(u32))
> +			goto failure;
>  		p->result = *(int*)RTA_DATA(tb[TCA_POLICE_RESULT-1]);
> +	}

Either these things are int's or u32's, they cannot be both :-)
I know that size wise it's identical, but at least make the code
look consistent.
