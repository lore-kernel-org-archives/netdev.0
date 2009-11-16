From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [PATCH 1/4] drivers/net/enic: decrement sizeof size in strncmp
Date: Mon, 16 Nov 2009 15:46:25 -0800
Message-ID: <C7272451.17157%scofeldm@cisco.com>
References: <Pine.LNX.4.64.0911120848100.16627@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
To: Julia Lawall <julia@diku.dk>, Joe Eykholt <jeykholt@cisco.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:14423 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755054AbZKPXqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 18:46:21 -0500
In-Reply-To: <Pine.LNX.4.64.0911120848100.16627@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Julia/Jorg.  We'll pick up change in next enic patch series.

-scott


On 11/11/09 11:48 PM, "Julia Lawall" <julia@diku.dk> wrote:

> From: Julia Lawall <julia@diku.dk>
> 
> As observed by Joe Perches, sizeof of a constant string includes the
> trailing 0.  If what is wanted is to check the initial characters of
> another string, this trailing 0 should not be taken into account.  If an
> exact match is wanted, strcmp should be used instead.
> 
> The semantic patch that makes this change is as follows:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @@
> expression foo;
> constant char *abc;
> @@
> 
> strncmp(foo, abc,
> - sizeof(abc)
> + sizeof(abc)-1
>  )
> // </smpl>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>
> 
> ---
>  drivers/net/enic/vnic_dev.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff -u -p a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
> --- a/drivers/net/enic/vnic_dev.c
> +++ b/drivers/net/enic/vnic_dev.c
> @@ -358,9 +358,9 @@ int vnic_dev_hw_version(struct vnic_dev
> if (err)
> return err;
>  
> - if (strncmp(fw_info->hw_version, "A1", sizeof("A1")) == 0)
> + if (strncmp(fw_info->hw_version, "A1", sizeof("A1") - 1) == 0)
> *hw_ver = VNIC_DEV_HW_VER_A1;
> - else if (strncmp(fw_info->hw_version, "A2", sizeof("A2")) == 0)
> + else if (strncmp(fw_info->hw_version, "A2", sizeof("A2") - 1) == 0)
> *hw_ver = VNIC_DEV_HW_VER_A2;
> else
> *hw_ver = VNIC_DEV_HW_VER_UNKNOWN;

