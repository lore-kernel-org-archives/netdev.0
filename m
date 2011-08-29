From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/2] ath: Make ath_printk void not int and remove
 unused struct ath_common *
Date: Mon, 29 Aug 2011 11:31:39 -0700
Message-ID: <1314642699.6852.23.camel@Joe-Laptop>
References: <cover.1314347556.git.joe@perches.com>
	 <78869fcd8172cd02266b66a71aadbd0c0efbdebc.1314347556.git.joe@perches.com>
	 <20110829181237.GB1406@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <lrodriguez@atheros.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:60872 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754495Ab1H2Sbl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Aug 2011 14:31:41 -0400
In-Reply-To: <20110829181237.GB1406@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-08-29 at 14:12 -0400, John W. Linville wrote:
> On Fri, Aug 26, 2011 at 01:56:39AM -0700, Joe Perches wrote:
> > Changing the return type and removing the unused argument from
> > ath_printk reduces code size.
> > Add an __always_unused struct ath_common * to the macros
> > that call ath_printk to avoid unused variable warnings.
> > $ size drivers/net/wireless/ath/built-in.o*
> >    text	   data	    bss	    dec	    hex	filename
> > 1159859	  16235	 212000	1388094	 152e3e	drivers/net/wireless/ath/built-in.o.new
> > 1164175	  16235	 212032	1392442	 153f3a	drivers/net/wireless/ath/built-in.o.old
[]
> > +#define _ath_printk(level, common, fmt, ...)			\
> > +do {								\
> > +	__always_unused struct ath_common *unused = common;	\
> > +	ath_printk(level, fmt, ##__VA_ARGS__);			\
> > +} while (0)
[]
> >  #define ath_emerg(common, fmt, ...)				\
> > -	ath_printk(KERN_EMERG, common, fmt, ##__VA_ARGS__)
> > +	_ath_printk(KERN_EMERG, common, fmt, ##__VA_ARGS__)
[]
> Any reason to preserve all these "common" args?

ath_dbg uses common, the other ath_<level>s do not.

So, other than to avoid modifying all the current uses?
Maybe just consistency or a future use case.

Or not.

I think using the macro to avoid larger line changes is
an acceptable minimal change.
