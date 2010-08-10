From: Joe Perches <joe@perches.com>
Subject: Re: [patch 2/2] qlcnic: using too much stack
Date: Mon, 09 Aug 2010 19:03:21 -0700
Message-ID: <1281405801.1954.65.camel@Joe-Laptop.home>
References: <20100809103727.GH9031@bicker>
	 <0081C370-65E2-434F-BBC6-C688F6F39750@qlogic.com>
	 <20100809184254.GJ9031@bicker>
	 <9F31A875-3A0B-4518-8106-1012E0D2799B@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <error27@gmail.com>,
	Amit Salecha <amit.salecha@qlogic.com>,
	Linux Driver <Linux-Driver@qlogic.com>,
	"David S. Miller" <davem@davemloft.net>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2340 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751925Ab0HJCDY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Aug 2010 22:03:24 -0400
In-Reply-To: <9F31A875-3A0B-4518-8106-1012E0D2799B@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-08-09 at 18:43 -0700, Anirban Chakraborty wrote:
> Your patch is fine except that the preferred way is to use kzalloc over kaclloc. kzalloc does not need that extra
> argument that you are passing to kcalloc.

You probably meant to write "my preferred way"
as the kcalloc to "kzalloc with a multiply"
ratio is pretty high.

It's actually about 2.5 to 1 in favor of kcalloc.

$ grep -rw --include=*.[ch] kcalloc * | wc -l
419

$ grep -rP --include=*.[ch] "\bkzalloc\s*\(\s*\w+\s*\*\s*\w+" * | \
  grep -vP "\bkzalloc\s*\(\s*sizeof\s+\*\s*\w+\s*," | wc -l
164

(the grep -vP avoids kzalloc(sizeof *p, GFP_foo)

Actually, there might be a reason to use kzalloc
in that location to match the other similar use
a few lines away, but I'd prefer that the other
use be converted to kcalloc.

cheers, Joe

