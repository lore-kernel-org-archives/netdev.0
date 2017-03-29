From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/7] netconf: Add support for RTM_DELNETCONF
Date: Wed, 29 Mar 2017 08:13:19 -0600
Message-ID: <295c0613-7ffd-5dfa-5ee3-aa5409445d92@cumulusnetworks.com>
References: <1490736487-16020-1-git-send-email-dsa@cumulusnetworks.com>
 <20170328.223257.1804803147939889749.davem@davemloft.net>
 <3cc67fc9-4169-1b8d-39b4-0b7f408637a7@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:37017 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751785AbdC2OOJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 10:14:09 -0400
Received: by mail-it0-f44.google.com with SMTP id 190so56831741itm.0
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 07:14:08 -0700 (PDT)
In-Reply-To: <3cc67fc9-4169-1b8d-39b4-0b7f408637a7@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/29/17 3:36 AM, Nicolas Dichtel wrote:
> Le 29/03/2017 à 07:32, David Miller a écrit :
>> From: David Ahern <dsa@cumulusnetworks.com>
>> Date: Tue, 28 Mar 2017 14:28:00 -0700
>>
>>> netconf notifications are sent as devices register but not when they
>>> are deleted leaving userspace caches out of sync. Add support for
>>> RTM_DELNETCONF to ipv4, ipv6 and mpls.
> Not sure why those notifications are needed. When an interface is set down, ipv4
> route deletion are not notified. Why is it needed for netconf?
> 

We carry a patch to send notifications for route deletes. In general, it
makes management of libnl caches much easier when delete notifications
are sent for each type. Without it, a link delete requires walking the
other caches removing objects.
