From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] bonding: Use do_div to divide 64 bit numbers
Date: Fri, 24 Jan 2014 02:25:28 +0400
Message-ID: <52E196D8.5060103@cogentembedded.com>
References: <1390502838-21581-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390502838-21581-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 23-01-2014 22:47, Zoltan Kiss wrote:

> Nikolay Aleksandrov's recent bonding option API changes (25a9b54a and e4994612)

    You should also specify those commits' summary lines.

> introduced u64 as the type of downdelay and updelay. On 32 bit the division and
> modulo operations cause compile errors:

> ERROR: "__udivdi3" [drivers/net/bonding/bonding.ko] undefined!
> ERROR: "__umoddi3" [drivers/net/bonding/bonding.ko] undefined!

> This patch use the do_div macro, which guaranteed to do the right thing.

> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> ---
>   drivers/net/bonding/bond_options.c |   19 +++++++++++--------
>   1 file changed, 11 insertions(+), 8 deletions(-)

> diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
> index 4cee04a..4f94907 100644
> --- a/drivers/net/bonding/bond_options.c
> +++ b/drivers/net/bonding/bond_options.c
[...]
> @@ -727,19 +728,20 @@ int bond_option_miimon_set(struct bonding *bond, struct bond_opt_value *newval)
>
>   int bond_option_updelay_set(struct bonding *bond, struct bond_opt_value *newval)
>   {
> +	u64 quotient = newval->value;
> +	u64 remainder = do_div(quotient, bond->params.miimon);

    Empty line after declarations wouldn't hurt here.

> @@ -750,19 +752,20 @@ int bond_option_updelay_set(struct bonding *bond, struct bond_opt_value *newval)
>   int bond_option_downdelay_set(struct bonding *bond,
>   			      struct bond_opt_value *newval)
>   {
> +	u64 quotient = newval->value;
> +	u64 remainder = do_div(quotient, bond->params.miimon);

    And here.

WBR, Sergei
