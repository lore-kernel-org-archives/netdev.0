From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v4 net-next 09/11] net: Add IPv6 flow label to flow_keys
Date: Fri, 22 May 2015 08:14:21 -0700
Message-ID: <CALx6S35PHMadpa49XXkrju3rDBujXHjAz7zd0GgkK_3JN8nkkA@mail.gmail.com>
References: <1432253506-3646977-1-git-send-email-tom@herbertland.com>
	<1432253506-3646977-10-git-send-email-tom@herbertland.com>
	<20150522081428.GH2138@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:36729 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422691AbbEVPOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 11:14:21 -0400
Received: by igbpi8 with SMTP id pi8so38003933igb.1
        for <netdev@vger.kernel.org>; Fri, 22 May 2015 08:14:21 -0700 (PDT)
In-Reply-To: <20150522081428.GH2138@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 22, 2015 at 1:14 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Fri, May 22, 2015 at 02:11:44AM CEST, tom@herbertland.com wrote:
>>In flow_dissector set the flow label in flow_keys for IPv6. This also
>>removes the shortcircuiting of flow dissection when a non-zero label
>>is present, the flow label can be considered to provide additional
>>entropy for a hash.
>>
>>Signed-off-by: Tom Herbert <tom@herbertland.com>
>>---
>> include/net/flow_dissector.h |  4 +++-
>> net/core/flow_dissector.c    | 37 +++++++++++++------------------------
>> 2 files changed, 16 insertions(+), 25 deletions(-)
>>
>>diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
>>index 08480fb..effe607 100644
>>--- a/include/net/flow_dissector.h
>>+++ b/include/net/flow_dissector.h
>>@@ -28,7 +28,8 @@ struct flow_dissector_key_basic {
>> };
>>
>> struct flow_dissector_key_tags {
>>-      u32     vlan_id:12;
>>+      u32     vlan_id:12,
>>+              flow_label:20;
>> };
>>
>> /**
>>@@ -111,6 +112,7 @@ enum flow_dissector_key_id {
>>       FLOW_DISSECTOR_KEY_ETH_ADDRS, /* struct flow_dissector_key_eth_addrs */
>>       FLOW_DISSECTOR_KEY_TIPC_ADDRS, /* struct flow_dissector_key_tipc_addrs */
>>       FLOW_DISSECTOR_KEY_VLANID, /* struct flow_dissector_key_flow_tags */
>>+      FLOW_DISSECTOR_KEY_FLOW_LABEL, /* struct flow_dissector_key_flow_label */
>
>
> I think it makes sense to pair FLOW_DISSECTOR_KEY_* with
> struct flow_dissector_key_*
>
> How about to have FLOW_DISSECTOR_KEY_TAGS istead of VLANID and FLOW_LABEL?
>

I thought about that, but it doesn't really save anything to be less
explicit as we still need a conditional at each occurrence. If someone
is only looking for IPv6 flow label and nothing else they are able to
do that.
