From: David Gibson <hermes@gibson.dropbear.id.au>
Subject: Re: [PATRCH] janitor: hermes: delete verify_area call
Date: Tue, 30 Sep 2003 14:51:10 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930045110.GG15200@zax>
References: <20030925215902.57f53822.rddunlap@osdl.org> <20030929052925.GA5037@zax> <20030929130608.156bbc2b.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030929130608.156bbc2b.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 29, 2003 at 01:06:08PM -0700, Randy.Dunlap wrote:
> On Mon, 29 Sep 2003 15:29:25 +1000 David Gibson <hermes@gibson.dropbear.id.au> wrote:
> 
> | On Thu, Sep 25, 2003 at 09:59:02PM -0700, Randy.Dunlap wrote:
> | > 
> | > Hi,
> | > Please apply to 2.6.0-test5-current.
> | > 
> | > Thanks,
> | 
> | Sorry, can you clarify why this verify_area() is not needed?
> 
> 
> Sure, I'll try to do that.
> There are several related reasons for it.
> 
> Summary:
> Using verify_area() [or access_ok()] is redundant if copy*user(),
> get_user(), or put_user() is being used, but must (*should*) be used
> if __copy*user(), __get_user(), or __put_user() are being used.
> 
> a.  [include/asm-i386/uaccess.h] verify_area: - Obsolete, use access_ok()
> 
> b.  copy_*_user() already calls access_ok() to validate the user address.
>     The __* versions of copy*user() and __get/put_user() do not use
>     access_ok(), so checking must be done before using them.

Ah, ok, thanks.  In that case presumably the other call to
verify_area() doesn't need to be there either...

-- 
David Gibson			| For every complex problem there is a
david@gibson.dropbear.id.au	| solution which is simple, neat and
				| wrong.
http://www.ozlabs.org/people/dgibson
