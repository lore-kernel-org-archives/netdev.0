From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH] Be explict with what we are !'ing
	in	ixgbe_sfp_config_module_task()
Date: Wed, 8 Apr 2009 10:52:03 -0700
Message-ID: <F169D4F5E1F1974DBFAFABF47F60C10A2572FED3@orsmsx507.amr.corp.intel.com>
References: <75761e1f53ed07c43a977d98b54d6467d8896530.1239165870.git.tony@bakeyournoodle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tony Breeds <tony@bakeyournoodle.com>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <75761e1f53ed07c43a977d98b54d6467d8896530.1239165870.git.tony@bakeyournoodle.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Tony Breeds wrote:
> GCC warns:
> drivers/net/ixgbe/ixgbe_main.c: In function
> 'ixgbe_sfp_config_module_task': 
> drivers/net/ixgbe/ixgbe_main.c:3920: warning: suggest parentheses
> around operand of '!' or change '&' to '&&' or '!' to '~' 
> 
> Which I think is right.  Bracket to remove ambiguity.
> 
> Signed-off-by: Tony Breeds <tony@bakeyournoodle.com>
> ---
>  drivers/net/ixgbe/ixgbe_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ixgbe/ixgbe_main.c
> b/drivers/net/ixgbe/ixgbe_main.c 
> index 9ef128a..9099634 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -3917,7 +3917,7 @@ static void ixgbe_sfp_config_module_task(struct
>  	work_struct *work) }
>  	hw->mac.ops.setup_sfp(hw);
> 
> -	if (!adapter->flags & IXGBE_FLAG_IN_SFP_LINK_TASK)
> +	if (!(adapter->flags & IXGBE_FLAG_IN_SFP_LINK_TASK))
>  		/* This will also work for DA Twinax connections */
>  		schedule_work(&adapter->multispeed_fiber_task);
>  	adapter->flags &= ~IXGBE_FLAG_IN_SFP_MOD_TASK;

you're extremely correct, thanks!

Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
------------------------------------------------------------------------------
This SF.net email is sponsored by:
High Quality Requirements in a Collaborative Environment.
Download a free trial of Rational Requirements Composer Now!
http://p.sf.net/sfu/www-ibm-com
