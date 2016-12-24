From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 1/2] drivers: net: ethernet: 3com: fix return value
Date: Sat, 24 Dec 2016 22:06:55 +0300
Message-ID: <4200be74-f7e7-db6b-a258-8fd178fef369@cogentembedded.com>
References: <1482541554.16278.2.camel@dillow-glaptop.roam.corp.google.com>
 <1482580958-15406-1-git-send-email-thomas.preisner+linux@fau.de>
 <1482580958-15406-2-git-send-email-thomas.preisner+linux@fau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-kernel@i4.cs.fau.de, milan.stephan+linux@fau.de
To: Thomas Preisner <thomas.preisner+linux@fau.de>, dave@thedillows.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482580958-15406-2-git-send-email-thomas.preisner+linux@fau.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 12/24/2016 03:02 PM, Thomas Preisner wrote:

> In a few cases the err-variable is not set to a negative error code if a
> function call fails and thus 0 is returned instead.
> It may be better to set err to the appropriate negative error code
> before returning.
>
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188841
>
> Reported-by: Pan Bian <bianpan2016@163.com>
> Signed-off-by: Thomas Preisner <thomas.preisner+linux@fau.de>
> Signed-off-by: Milan Stephan <milan.stephan+linux@fau.de>
> ---
>  drivers/net/ethernet/3com/typhoon.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
> index a0cacbe..c88b88a 100644
> --- a/drivers/net/ethernet/3com/typhoon.c
> +++ b/drivers/net/ethernet/3com/typhoon.c
[...]
> @@ -2411,7 +2412,8 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	 * later when we print out the version reported.
>  	 */
>  	INIT_COMMAND_WITH_RESPONSE(&xp_cmd, TYPHOON_CMD_READ_VERSIONS);
> -	if(typhoon_issue_command(tp, 1, &xp_cmd, 3, xp_resp) < 0) {
> +	err = typhoon_issue_command(tp, 1, &xp_cmd, 3, xp_resp);
> +	if(err < 0) {

    Need a space between *if* and (. Run your patches thru 
scripts/checkpatch.pl before posting, please.

>  		err_msg = "Could not get Sleep Image version";
>  		goto error_out_reset;
>  	}
> @@ -2453,7 +2455,8 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	dev->features = dev->hw_features |
>  		NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_RXCSUM;
>
> -	if(register_netdev(dev) < 0) {
> +	err = register_netdev(dev);
> +	if(err < 0) {

    Same here.

[...]

MBR, Sergei
