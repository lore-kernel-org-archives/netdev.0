From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/3] l3mdev: Improve use with main table
Date: Thu, 20 Apr 2017 08:25:37 -0600
Message-ID: <dae262ea-681b-db1f-bc97-30f2e3c13aad@cumulusnetworks.com>
References: <1491834122-26252-1-git-send-email-rshearma@brocade.com>
 <822ee9b5-09d6-6987-deb3-6af9d537c891@cumulusnetworks.com>
 <a7204fbc-68b5-c6f4-c76c-d33b9c85d663@brocade.com>
 <e9cbd091-bb51-6f30-f31b-9080145caa93@cumulusnetworks.com>
 <256c2549-b831-2e7e-b18b-69243bb33ce3@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f176.google.com ([209.85.213.176]:35633 "EHLO
        mail-yb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032303AbdDTOZj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 10:25:39 -0400
Received: by mail-yb0-f176.google.com with SMTP id 6so26529921ybq.2
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 07:25:39 -0700 (PDT)
In-Reply-To: <256c2549-b831-2e7e-b18b-69243bb33ce3@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/20/17 7:01 AM, Robert Shearman wrote:
>> The cached dst on sockets is one known place that causes a hang on a
>> delete. Basically the delete stalls until the sockets are closed. I have
>> a patch for sk_rx_dst which is the one I chased down last week.

I got to the bottom on the sk_rx_dst caching -- it is only a problem on
older kernels (e.g., our 4.1 kernels) and only with multicast udp
sockets. The early demux code in 4.1 is matching a listen socket when it
should not. The early demux code for mcast had some changes unrelated to
false matching that fixed the problem.
