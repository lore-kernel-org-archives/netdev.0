From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 1/3] net: add support for phys_port_name
Date: Mon, 16 Mar 2015 17:15:47 +0100
Message-ID: <20150316161547.GG2058@nanopsycho.orion>
References: <1426520818-11198-1-git-send-email-dsahern@gmail.com>
 <20150316160000.GD2058@nanopsycho.orion>
 <5506FE81.2010602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Scott Feldman <sfeldma@gmail.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:37267 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933824AbbCPQQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 12:16:03 -0400
Received: by wixw10 with SMTP id w10so47921178wix.0
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 09:15:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5506FE81.2010602@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 16, 2015 at 05:02:09PM CET, dsahern@gmail.com wrote:
>On 3/16/15 10:00 AM, Jiri Pirko wrote:
>>>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>>>index dd1d069758be..47a773b9bee0 100644
>>>>--- a/include/linux/netdevice.h
>>>>+++ b/include/linux/netdevice.h
>>>>@@ -765,6 +765,15 @@ struct netdev_phys_item_id {
>>>>	unsigned char id_len;
>>>>};
>>>>
>>>>+#define MAX_PHYS_ITEM_NAME_LEN 32
>>>>+
>>>>+/* This structure holds a unique name to identify some
>>>>+ * physical item (port for example) used by a netdevice.
>>>>+ */
>>>>+struct netdev_phys_item_name {
>>>>+	char str[MAX_PHYS_ITEM_NAME_LEN];
>>>>+};
>>>>+
>>>>typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>>>>				       struct sk_buff *skb);
>>>>
>>>>@@ -1159,6 +1168,8 @@ struct net_device_ops {
>>>>						      bool new_carrier);
>>>>	int			(*ndo_get_phys_port_id)(struct net_device *dev,
>>>>							struct netdev_phys_item_id *ppid);
>>>>+	int			(*ndo_get_phys_port_name)(struct net_device *dev,
>>>>+							  struct netdev_phys_item_name *name);
>>I think that we do not need the structure. Just pass "char *name" for buffer
>>where to put the name and "size_t len" for len of the buffer. Have:
>>#define PORT_NAME_MAX_LEN 32
>>and have called to have "char name[PORT_NAME_MAX_LEN]"
>>
>>Also, given that this is related to switches, won't it make sense to
>>push this into switchdev code?
>>
>>
>
>Doesn't seem right to have assumptions on buffer length like that.

There are no assumptions. You pass real buffer length in len parameter.

>
>David
