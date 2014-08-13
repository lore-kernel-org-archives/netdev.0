From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH V2] net: ethernet: myricom: myri10ge: myri10ge.c:
  Cleaning up missing null-terminate after strncpy call
Date: Wed, 13 Aug 2014 19:06:39 +0200
Message-ID: <20140813170639.GB1869@nanopsycho.orion>
References: <1407784696-31698-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hyong-Youb Kim <hykim@myri.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1407784696-31698-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mon, Aug 11, 2014 at 09:18:16PM CEST, rickard_strandqvist@spectrumdigital.se wrote:
>Added a guaranteed null-terminate after call to strncpy.
>
>Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
>---
> drivers/net/ethernet/myricom/myri10ge/myri10ge.c |    1 +
> 1 file changed, 1 insertion(+)
>
>diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
>index f3d5d79..69c26f0 100644
>--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
>+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
>@@ -574,6 +574,7 @@ myri10ge_validate_firmware(struct myri10ge_priv *mgp,
> 
> 	/* save firmware version for ethtool */
> 	strncpy(mgp->fw_version, hdr->version, sizeof(mgp->fw_version));
>+	mgp->fw_version[sizeof(mgp->fw_version) - 1] = '\0';

	Why not to use strlcpy?

> 
> 	sscanf(mgp->fw_version, "%d.%d.%d", &mgp->fw_ver_major,
> 	       &mgp->fw_ver_minor, &mgp->fw_ver_tiny);
>-- 
>1.7.10.4
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
