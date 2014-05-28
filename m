From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 0/2] macvlan: fix the problem when mac address
 changes for passthru mode
Date: Wed, 28 May 2014 12:24:05 -0400
Message-ID: <53860DA5.8090407@gmail.com>
References: <1401106233-11320-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>, kaber@trash.net,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:43559 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753478AbaE1QYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 12:24:11 -0400
Received: by mail-qg0-f42.google.com with SMTP id q107so18932522qgd.1
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 09:24:10 -0700 (PDT)
In-Reply-To: <1401106233-11320-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/26/2014 08:10 AM, Ding Tianhong wrote:
> Ding Tianhong (2):
>   macvlan: don't change macvlan address alone for passthru mode
>   macvlan: propagate lowerdev mac address changes for passthru mode
> 
>  drivers/net/macvlan.c | 40 +++++++++++++++++++++++++++++++---------
>  1 file changed, 31 insertions(+), 9 deletions(-)
> 

This ends up working kind-of backwards...  A user now has to know
that passthru macvlans he has to change the lower-level mac, but
for all others, changing the macvlan mac is ok and will work...

This also will not work if the passthru macvlan is stacked on
something other the hw (for example: a vlan).

Why not simply propagate the mac address change of the passhtru macvlan
down to the real device?

Thanks
-vlad
