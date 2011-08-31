From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH 2/2] Add a netlink attribute INET_DIAG_SECCTX
Date: Wed, 31 Aug 2011 08:08:30 -0400
Message-ID: <1314792510.6850.7.camel@moss-pluto>
References: <1314779777-12669-1-git-send-email-rongqing.li@windriver.com>
	 <1314779777-12669-3-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org
To: rongqing.li@windriver.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1314779777-12669-3-git-send-email-rongqing.li@windriver.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-08-31 at 16:36 +0800, rongqing.li@windriver.com wrote:
> From: Roy.Li <rongqing.li@windriver.com>
> 
> Add a new netlink attribute INET_DIAG_SECCTX to dump the security
> context of TCP sockets.
> 
> The element sk_security of struct sock represents the socket
> security context ID, which is inherited from the parent process
> when the socket is created.
> 
> but when SELinux type_transition rule is applied to socket, or
> application sets /proc/xxx/attr/createsock, the socket security
> context would be different from the creating process. For these
> conditions, the "netstat -Z" will return wrong value, since
> "netstat -Z" only returns the process security context as socket
> process security.
> 
> Signed-off-by: Roy.Li <rongqing.li@windriver.com>
> ---
>  include/linux/inet_diag.h |    3 ++-
>  net/ipv4/inet_diag.c      |   38 +++++++++++++++++++++++++++++++++-----
>  2 files changed, 35 insertions(+), 6 deletions(-)

> diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
> index 389a2e6..1faf752 100644
> --- a/net/ipv4/inet_diag.c
> +++ b/net/ipv4/inet_diag.c
> @@ -34,6 +34,8 @@
>  
>  #include <linux/inet_diag.h>
>  
> +#define MAX_SECCTX_LEN 128

We don't impose such a (low) limit on other interfaces for reporting
security contexts.  Can you just size the buffer appropriately for the
actual secctx length?

-- 
Stephen Smalley
National Security Agency

