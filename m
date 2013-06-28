From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v3 1/2] lib: vsprintf: add IPv4/v6 generic
 %p[Ii]S[pfs] format specifier
Date: Fri, 28 Jun 2013 09:30:39 -0700
Message-ID: <1372437039.29380.19.camel@joe-AO722>
References: <1372421131-1672-1-git-send-email-dborkman@redhat.com>
	 <1372421131-1672-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, linux-kernel@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372421131-1672-2-git-send-email-dborkman@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-06-28 at 14:05 +0200, Daniel Borkmann wrote:

> +static noinline_for_stack
> +char *ip4_addr_string_sa(char *buf, char *end, const struct sockaddr_in *sa,
> +			 struct printf_spec spec, const char *fmt)
> +{
> +	bool have_p = (fmt[2] && fmt[2] == 'p');

	bool have_p = fmt[2] == 'p';

you don't need the first "fmt[2] &&"
but I can imagine a case where the other flow/scope types
could be specified generically and the 'p' may not be in
array index 2

I think you should probably do the same while loop like
the ip6_addr_string_sa block.
