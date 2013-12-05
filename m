From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] ether_addr_equal: Optimize implementation,
 remove unused compare_ether_addr
Date: Thu, 05 Dec 2013 15:36:55 -0800
Message-ID: <1386286615.10003.30.camel@joe-AO722>
References: <34a0bad292ab2535a3a2e757a83eca13408e55b7.1386283991.git.joe@perches.com>
	 <20131205153229.187f7604@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Rob Landley <rob@landley.net>,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20131205153229.187f7604@nehalam.linuxnetplumber.net>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-12-05 at 15:32 -0800, Stephen Hemminger wrote:
> On Thu,  5 Dec 2013 14:54:38 -0800
> Joe Perches <joe@perches.com> wrote:
> 
> > +#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
> > +	u32 fold = ((*(const u32 *)addr1) ^ (*(const u32 *)addr2)) |
> > +		   ((*(const u16 *)(addr1 + 4)) ^ (*(const u16 *)(addr2 + 4)));
> > +
> > +	return fold == 0;
> 
> Why the temporary variable.

It's cost free and I think a bit more readable.

>  You can just do:
> 	return ((*(const u32 *)addr1) ^ (*(const u32 *)addr2)) |
> 	       ((*(const u16 *)(addr1 + 4)) ^ (*(const u16 *)(addr2 + 4))) != 0;

== 0

> Or
> 	return !!((*(const u32 *)addr1) ^ (*(const u32 *)addr2)) |
> 	         ((*(const u16 *)(addr1 + 4)) ^ (*(const u16 *)(addr2 + 4))));

!!!? :)


