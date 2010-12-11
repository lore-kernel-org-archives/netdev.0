From: Kees Cook <kees.cook@canonical.com>
Subject: Re: [PATCH v2] kptr_restrict for hiding kernel pointers from
 unprivileged users
Date: Fri, 10 Dec 2010 16:11:51 -0800
Message-ID: <20101211001151.GS4464@outflux.net>
References: <1292025924.2965.20.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	jmorris@namei.org, eugeneteo@kernel.org, mingo@elte.hu,
	davem@davemloft.net
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1292025924.2965.20.camel@Dan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 10, 2010 at 07:05:24PM -0500, Dan Rosenberg wrote:
> The below patch adds the %pK format specifier, the
> CONFIG_SECURITY_KPTR_RESTRICT configuration option, and the
> kptr_restrict sysctl.
> 
> The %pK format specifier is designed to hide exposed kernel pointers
> from unprivileged users, specifically via /proc interfaces.  Its
> behavior depends on the kptr_restrict sysctl, whose default value
> depends on CONFIG_SECURITY_KPTR_RESTRICT.  If kptr_restrict is set to 0,
> no deviation from the standard %p behavior occurs.  If kptr_restrict is
> set to 1, if the current user (intended to be a reader via seq_printf(),
> etc.) does not have CAP_SYSLOG (which is currently in the LSM tree),
> kernel pointers using %pK are printed as 0's.  This was chosen over the
> default "(null)", which cannot be parsed by userland %p, which expects
> "(nil)".
> 
> v2 improves checking for inappropriate context, on suggestion by Peter
> Zijlstra.  Thanks to Thomas Graf for suggesting use of a centralized
> format specifier.
> 
> Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>

This will come in very handy! Thanks for working on this approach. :)

Acked-by: Kees Cook <kees.cook@canonical.com>

-Kees

-- 
Kees Cook
Ubuntu Security Team
