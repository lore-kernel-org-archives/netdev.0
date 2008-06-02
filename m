From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [RFC] Running single tests via ethtool
Date: Mon, 2 Jun 2008 19:00:17 +0200
Message-ID: <200806021900.17817.netdev@axxeo.de>
References: <20080530220819.GJ1743@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:56799 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752138AbYFBRA2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2008 13:00:28 -0400
In-Reply-To: <20080530220819.GJ1743@solarflare.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ben,

Ben Hutchings schrieb:
> We have had a customer request to be able to run individual self-tests in
> a future version of our driver.  Now we could do this any way we want in
> an out-of-tree driver, but I'd rather find some way of doing this that
> will also be acceptable in-tree.  I think that would mean extending the
> ethtool self-test API in some way.
> 
> One possibility might be to add a new flag and to assign the reserved field
> as a test index:
> 
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -235,13 +235,14 @@ struct ethtool_gstrings {
>  enum ethtool_test_flags {
>  	ETH_TEST_FL_OFFLINE	= (1 << 0),	/* online / offline */
>  	ETH_TEST_FL_FAILED	= (1 << 1),	/* test passed / failed */
> +	ETH_TEST_FL_SINGLE	= (1 << 2),	/* run single test */
>  };
>  
>  /* for requesting NIC test and getting results*/
>  struct ethtool_test {
>  	__u32	cmd;		/* ETHTOOL_TEST */
>  	__u32	flags;		/* ETH_TEST_FL_xxx */
> -	__u32	reserved;
> +	__u32	index;		/* test index if ETH_TEST_FL_SINGLE */
>  	__u32	len;		/* result length, in number of u64 elements */
>  	__u64	data[0];
>  };

2^32 possible tests are really an extensive test suite :-)

Maybe limit it to 16 bits, so we have some reserved space left for further
extensions.


Best Regards

Ingo Oeser
