From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 1/6] net-PPP: Replacement of a printk() call by
 pr_warn() in mppe_rekey()
Date: Thu, 04 Dec 2014 23:41:27 -0800
Message-ID: <1417765287.2721.39.camel@perches.com>
References: <1417731809.2721.17.camel@perches.com>
	 <alpine.DEB.2.02.1412050820290.2059@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: SF Markus Elfring <elfring@users.sourceforge.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1412050820290.2059@localhost6.localdomain6>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-12-05 at 08:21 +0100, Julia Lawall wrote:
> On Thu, 4 Dec 2014, Joe Perches wrote:
> > It's generally nicer to replace embedded function names
> > with "%s: ", __func__
> > 
> > 			pr_warn("%s: cipher_encrypt failed\n", __func__);
> 
> Doing so may potentially allow some strings to be shared, thus saving a 
> little space.  Perhaps not in this case, though.

It's not necessarily a code size savings in any case.

It can be, but the real benefits are stylistic
consistency and lack of mismatch between function
name and message.

If the code is refactored or copy/pasted into another
function, a moderately common defect is not modifying
the embedded function name in the message.

There may be some smallish savings if ever these
__func__ uses were converted to use %pf via some
internal standardized mechanism.

A negative to that approach is inlined functions would
take the function name of the parent not keep the
inlined function name.


