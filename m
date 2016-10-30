From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net-next 2/2] net/mlx4_en: Refactor the XDP forwarding
 rings scheme
Date: Sun, 30 Oct 2016 18:03:06 +0200
Message-ID: <34ee2e3e-a2ad-2104-9444-ae9c7fed55b7@gmail.com>
References: <1477579924-32737-1-git-send-email-tariqt@mellanox.com>
 <1477579924-32737-3-git-send-email-tariqt@mellanox.com>
 <20161028010701.GB49550@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35923 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754926AbcJ3QDK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 12:03:10 -0400
Received: by mail-wm0-f66.google.com with SMTP id c17so14996873wmc.3
        for <netdev@vger.kernel.org>; Sun, 30 Oct 2016 09:03:10 -0700 (PDT)
In-Reply-To: <20161028010701.GB49550@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 28/10/2016 4:07 AM, Alexei Starovoitov wrote:
> On Thu, Oct 27, 2016 at 05:52:04PM +0300, Tariq Toukan wrote:
>> Separately manage the two types of TX rings: regular ones, and XDP.
>> Upon an XDP set, do not borrow regular TX rings and convert them
>> into XDP ones, but allocate new ones, unless we hit the max number
>> of rings.
>> Which means that in systems with smaller #cores we will not consume
>> the current TX rings for XDP, while we are still in the num TX limit.
> The commit log is too scarce for details...
> So questions:
> - Did you test with changing the number of channels after xdp prog is loaded?
> That was the recent bug that Brenden fixed.
Bug no longer exists, as the indices of the XDP TX rings now start from 
0, each is identical to its respective RX ring.
Brenden's fix didn't get to net-next yet, and it shouldn't once the 
series is applied.
I need to take this w Dave.
> - does it still have 256 tx queue limit or xdp tx rings can go over?
It still has the limit of 256 TX queues.
> - Any performance implications ?
I didn't see any performance implications.
Note that the XDP TX rings are no longer shown in ethtool -S.
>
> Brenden, could you please review this patch?
>
Regards,
Tariq
