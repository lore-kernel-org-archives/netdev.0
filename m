From: =?UTF-8?Q?Jan_Grash=c3=b6fer?= <jan.grashoefer@gmail.com>
Subject: Re: Receiving raw packets (incl. VLAN tags) on raw sockets
Date: Wed, 14 Jun 2017 18:03:27 +0200
Message-ID: <8e65d057-a39c-6b83-b650-922ba9e86051@gmail.com>
References: <e06dbb47-2d1c-03ca-4cd7-cc958b6a939e@gmail.com>
 <877f0eaax8.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aeppert@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:36045 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752230AbdFNQDa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 12:03:30 -0400
Received: by mail-wr0-f182.google.com with SMTP id 36so6618681wry.3
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 09:03:30 -0700 (PDT)
In-Reply-To: <877f0eaax8.fsf@xmission.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/06/17 16:41, Eric W. Biederman wrote:
> That does not work.  That is is just the software fallback for when
> the device driver does not have a special case the processing
> vlan tagged packets.
> 
> There was a major inconsistency that for a long time the hardware
> network drivers were stripping tags and the software ones were not.
> 
> The code you are playing with is the fix for the rare slow path
> that does not happen to strip the tags.  Disabling the rare slow path
> might temporarily solve your symptoms but it will be much more painful
> when you are entrenched in your ways and discover that high performance
> hardware behaves differently than your software device.

Thanks for your reply! Actually, I was referring to COTS hardware that 
incorporates offloading features. But, when it comes to (security) 
monitoring, offloading is usually disabled [1,2] to process the packets 
as seen on the wire. Thus the "slow path" would be the default path for 
most monitoring applications. That is, what makes this situation kind of 
weird. After turning off the NIC's VLAN offloading, it took me some time 
to realize that now the kernel strips off VLAN tags. If someone decides 
that VLAN offloading is not needed, I think the kernel should not 
enforce it.

Jan

[1] 
https://redmine.openinfosecfoundation.org/projects/suricata/wiki/File_Extraction#NIC-offloading
[2] 
https://www.bro.org/documentation/faq.html#capture-loss-without-dropped-packets
