From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH] openvswitch: Add packet truncation support.
Date: Thu, 9 Jun 2016 11:17:55 -0700
Message-ID: <CAOrHB_BUYhZxOMrs4EJyCA1Z8UTYKCNLv3G1rEX5LHP_yamxDw@mail.gmail.com>
References: <1465435105-21777-1-git-send-email-u9012063@gmail.com>
 <CAOrHB_CNZ2_JCt7RCaMQehZvYxZO-3wL00krbPX-iT1z3iAu=w@mail.gmail.com> <575991E1.9020906@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: William Tu <u9012063@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:42567 "EHLO
	slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932785AbcFISSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 14:18:37 -0400
Received: from relay6-d.mail.gandi.net (relay6-d.mail.gandi.net [217.70.183.198])
	by slow1-d.mail.gandi.net (Postfix) with ESMTP id 51DBA47AADF
	for <netdev@vger.kernel.org>; Thu,  9 Jun 2016 20:18:00 +0200 (CEST)
Received: from mfilter26-d.gandi.net (mfilter26-d.gandi.net [217.70.178.154])
	by relay6-d.mail.gandi.net (Postfix) with ESMTP id A60DBFB887
	for <netdev@vger.kernel.org>; Thu,  9 Jun 2016 20:17:58 +0200 (CEST)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
	by mfilter26-d.gandi.net (mfilter26-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id GWKwKU49Ksuy for <netdev@vger.kernel.org>;
	Thu,  9 Jun 2016 20:17:57 +0200 (CEST)
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	(Authenticated sender: pshelar@ovn.org)
	by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 4BAC0FB8A1
	for <netdev@vger.kernel.org>; Thu,  9 Jun 2016 20:17:57 +0200 (CEST)
Received: by mail-io0-f175.google.com with SMTP id 5so45388647ioy.1
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 11:17:57 -0700 (PDT)
In-Reply-To: <575991E1.9020906@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 9, 2016 at 8:57 AM, Rick Jones <rick.jones2@hpe.com> wrote:
> On 06/08/2016 09:30 PM, pravin shelar wrote:
>>
>> On Wed, Jun 8, 2016 at 6:18 PM, William Tu <u9012063@gmail.com> wrote:
>>>
>>> +struct ovs_action_trunc {
>>> +       uint32_t max_len; /* Max packet size in bytes. */
>>
>> This could uint16_t. as it is related to packet len.
>>
>
> Is there something limiting MTUs to 65535 bytes?
>
I was thinking of typical traffic, ip, ip6. But since linux skb can
have handle larger packet lets keep this field 32bit.
So now we also needs cutlen to be 32 bit.
