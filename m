From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC] Running single tests via ethtool
Date: Mon, 02 Jun 2008 13:46:47 -0400
Message-ID: <48443207.5090009@garzik.org>
References: <20080530220819.GJ1743@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43514 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751727AbYFBRqt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2008 13:46:49 -0400
In-Reply-To: <20080530220819.GJ1743@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
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
> 
> Clients would need to check len on return since the ethtool core and driver
> ethtool functions ignore unknown flags.  I am assuming that running all
> online self-tests instead of a single self-test will be harmless.
> 
> Ideally the ethtool core would allocate only the necessary memory for the
> results of the selected test set or single test, but it would need to know
> whether the driver also supports this extension.

Well it really becomes of question of whether or not you want to be 
importing a huge test suite into a kernel driver.  The ethtool stuff was 
not meant to cover exhaustive tests, just a way to run "it works" 
self-checks and diagnostics.

	Jeff




