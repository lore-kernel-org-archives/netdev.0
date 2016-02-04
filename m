From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5 2/2] virtio_net: add ethtool support for set
 and get of settings
Date: Thu, 4 Feb 2016 13:26:28 +0100
Message-ID: <56B34374.90709@cumulusnetworks.com>
References: <1454468677-12280-1-git-send-email-razor@blackwall.org>
 <1454468677-12280-3-git-send-email-razor@blackwall.org>
 <20160204141947-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:33795 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751873AbcBDM0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 07:26:30 -0500
Received: by mail-wm0-f47.google.com with SMTP id 128so24564361wmz.1
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 04:26:30 -0800 (PST)
In-Reply-To: <20160204141947-mutt-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/2016 01:21 PM, Michael S. Tsirkin wrote:
> On Wed, Feb 03, 2016 at 04:04:37AM +0100, Nikolay Aleksandrov wrote:
>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
[snip]
>>  struct padded_vnet_hdr {
>> @@ -1376,6 +1380,58 @@ static void virtnet_get_channels(struct net_device *dev,
>>  	channels->other_count = 0;
>>  }
>>  
>> +/* Check if the user is trying to change anything besides speed/duplex */
>> +static bool virtnet_validate_ethtool_cmd(const struct ethtool_cmd *cmd)
>> +{
>> +	struct ethtool_cmd diff1 = *cmd;
>> +	struct ethtool_cmd diff2 = {};
>> +
>> +	/* advertising and cmd are usually set, ignore port because we set it */
> 
> We set it where?
If you're asking about advertising - ethtool sets it automatically when the
user tries to set both speed and duplex together.

> Instead of this, should not we set diff2.port to PORT_OTHER?
> 
Yes, that will validate it too.

>> +	ethtool_cmd_speed_set(&diff1, 0);
>> +	diff1.advertising = 0;
>> +	diff1.duplex = 0;
>> +	diff1.port = 0;
>> +	diff1.cmd = 0;
>> +
>> +	return !memcmp(&diff1, &diff2, sizeof(diff1));
>> +}
>> +
[snip]
