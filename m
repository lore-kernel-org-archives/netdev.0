From: Jim Dykman <dykmanj@linux.vnet.ibm.com>
Subject: Re: [PATCH 27/27] HFI: hf ethtool support
Date: Wed, 02 Mar 2011 17:28:42 -0500
Message-ID: <4D6EC49A.9060405@linux.vnet.ibm.com>
References: <1299100213-8770-1-git-send-email-dykmanj@linux.vnet.ibm.com> <1299100213-8770-27-git-send-email-dykmanj@linux.vnet.ibm.com> <1299102762.4277.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Piyush Chaudhary <piyushc@linux.vnet.ibm.com>,
	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>,
	"William S. Cadden" <wscadden@linux.vnet.ibm.com>,
	"Wen C. Chen" <winstonc@linux.vnet.ibm.com>,
	Scot Sakolish <sakolish@linux.vnet.ibm.com>,
	Jian Xiao <jian@linux.vnet.ibm.com>,
	"Carol L. Soto" <clsoto@linux.vnet.ibm.com>,
	"Sarah J. Sheppard" <sjsheppa@linux.vnet.ibm.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:60155 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754516Ab1CBW2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 17:28:53 -0500
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p22MMQbT004856
	for <netdev@vger.kernel.org>; Wed, 2 Mar 2011 15:22:26 -0700
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p22MSqIB105330
	for <netdev@vger.kernel.org>; Wed, 2 Mar 2011 15:28:52 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p22MXX5k029885
	for <netdev@vger.kernel.org>; Wed, 2 Mar 2011 15:33:34 -0700
In-Reply-To: <1299102762.4277.4.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/2/2011 4:52 PM, Ben Hutchings wrote:
> On Wed, 2011-03-02 at 16:10 -0500, dykmanj@linux.vnet.ibm.com wrote:
> [...]
>> +static int hf_get_sset_count(struct net_device *netdev, int sset)
>> +{
>> +	switch (sset) {
>> +	case ETH_SS_STATS:
>> +		return ARRAY_SIZE(hf_ethtool_stats_keys);
>> +	default:
>> +		return -EOPNOTSUPP;
> 
> The error code should be -EINVAL, I think.

ok

> 
>> +	}
>> +}
>> +
>> +static void hf_get_ethtool_stats(struct net_device *netdev,
>> +		struct ethtool_stats *stats, u64 *data)
>> +{
>> +	struct hf_net	*net = netdev_priv(netdev);
>> +	struct hf_if	*net_if = &(net->hfif);
>> +
>> +	memcpy(data, &(net_if->eth_stats), sizeof(struct hf_ethtool_stats));
> [...]
> 
> This may result in word tearing, particularly if this driver can be
> built for a 32-bit system.  Since the stats appear to be updated
> asynchronously in the data path, you may have to declare them as
> unsigned long and then extend them to 64-bit in hf_get_ethtool_stats().
> 
> Ben.
> 

It is 64-bit only, but we forgot to mention that in Kconfig.

Thanks.

Jim Dykman

