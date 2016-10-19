From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: Useless debug warning "netlink: 16 bytes leftover after parsing
 attributes"
Date: Wed, 19 Oct 2016 17:50:50 +0200
Message-ID: <04216bf5-84a7-b6ea-57ff-9cb29a706510@6wind.com>
References: <0756CFFC-5BF7-4685-A1E2-0D88B2898454@holtmann.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: Michal Schmidt <mschmidt@redhat.com>
To: Marcel Holtmann <marcel@holtmann.org>,
        Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:33382 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945799AbcJSPu4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 11:50:56 -0400
Received: by mail-lf0-f50.google.com with SMTP id x79so32477808lff.0
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 08:50:54 -0700 (PDT)
In-Reply-To: <0756CFFC-5BF7-4685-A1E2-0D88B2898454@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 18/10/2016 à 07:06, Marcel Holtmann a écrit :
> Hi,
> 
> so lately I am seeing a bunch of these warnings:
> 
> netlink: 16 bytes leftover after parsing attributes..
> 
> While they give you the process name, they are still useless to track down the message that causes them. I find them even more useless since an updated userspace on an older kernel can trigger the nla_policy warning here. And that updated userspace program is doing nothing wrong by including extra attributes. So what purpose is this warning serving?
Usually, it means that a netlink message is malformed, for example that the
header of the family has the wrong size. An unknown attribute should not trigger
this kind of message.
Here is an example:
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=e5eca6d41f53d


Regards,
Nicolas
