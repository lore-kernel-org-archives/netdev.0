From: david decotigny <ddecotig@gmail.com>
Subject: Re: [PATCH net-next] ethtool: Set cmd field in =?utf-8?b?RVRIVE9PTF9HTElOS1NFVFRJTkdT?= response to wrong nwords
Date: Tue, 15 Mar 2016 19:00:15 +0000 (UTC)
Message-ID: <loom.20160315T195643-598@post.gmane.org>
References: <20160314010537.GD21187@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:57830 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934145AbcCOTFI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Mar 2016 15:05:08 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1afuHA-0006pf-Tk
	for netdev@vger.kernel.org; Tue, 15 Mar 2016 20:05:05 +0100
Received: from 104.132.1.68 ([104.132.1.68])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 20:05:04 +0100
Received: from ddecotig by 104.132.1.68 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 20:05:04 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <ben <at> decadent.org.uk> writes:
> 
> When the ETHTOOL_GLINKSETTINGS implementation finds that userland is
> using the wrong number of words of link mode bitmaps (or is trying to
> find out the right numbers) it sets the cmd field to 0 in the response
> structure.
> 
> This is inconsistent with the implementation of every other ethtool
> command, so let's remove that inconsistency before it gets into a
> stable release.
> 
> Fixes: 3f1ac7a700d03 ("net: ethtool: add new ETHTOOL_xLINKSETTINGS API")
> Signed-off-by: Ben Hutchings <ben <at> decadent.org.uk>
> ---
> David, please can you include this in changes for 4.6?
> 
> Ben.
> 
>  net/core/ethtool.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 2966cd0d7c93..f426c5ad6149 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
>  <at>  <at>  -655,7 +655,7  <at>  <at>  static int 
ethtool_get_link_ksettings(struct net_device *dev,
>  	    != link_ksettings.base.link_mode_masks_nwords) {
>  		/* wrong link mode nbits requested */
>  		memset(&link_ksettings, 0, sizeof(link_ksettings));
> -		/* keep cmd field reset to 0 */
> +		link_ksettings.base.cmd = ETHTOOL_GLINKSETTINGS;
>  		/* send back number of words required as negative val */
>  		compiletime_assert(__ETHTOOL_LINK_MODE_MASK_NU32 <= S8_MAX,
>  				   "need too many bits for link modes!");
> 

thanks!

Please also update the comments in ethtool.h, proposed change below:

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 2835b07..9222db8 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1648,9 +1648,9 @@ enum ethtool_reset_flags {
  *	%ETHTOOL_GLINKSETTINGS: on entry, number of words passed by user
  *	(>= 0); on return, if handshake in progress, negative if
  *	request size unsupported by kernel: absolute value indicates
- *	kernel recommended size and cmd field is 0, as well as all the
- *	other fields; otherwise (handshake completed), strictly
- *	positive to indicate size used by kernel and cmd field is
+ *	kernel expected size and all the other fields but cmd
+ *	are 0; otherwise (handshake completed), strictly positive
+ *	to indicate size used by kernel and cmd field stays
  *	%ETHTOOL_GLINKSETTINGS, all other fields populated by driver. For
  *	%ETHTOOL_SLINKSETTINGS: must be valid on entry, ie. a positive
  *	value returned previously by %ETHTOOL_GLINKSETTINGS, otherwise
