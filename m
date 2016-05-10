From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V1 1/3] net: bulk alloc and reuse of SKBs in
 NAPI context
Date: Tue, 10 May 2016 06:48:54 -0700
Message-ID: <1462888134.23934.60.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160509134352.3573.37044.stgit@firesoul>
	 <20160509134429.3573.4048.stgit@firesoul>
	 <CAKgT0Uftr643AR9n2=_aQmaGJO3eEyKTuaCfXwEKbYj1rVruRw@mail.gmail.com>
	 <20160509215956.19ec1c10@redhat.com>
	 <CAKgT0UfKzKWnNzGpB-915by2M1nzDAdNz-hDwwcwGoowmZefrg@mail.gmail.com>
	 <20160510143017.212c3846@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34111 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644AbcEJNs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 09:48:56 -0400
Received: by mail-pa0-f50.google.com with SMTP id r5so6120502pag.1
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 06:48:55 -0700 (PDT)
In-Reply-To: <20160510143017.212c3846@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-05-10 at 14:30 +0200, Jesper Dangaard Brouer wrote:

> Disable busy poll on both client and server, Not patched:
> 
>  $ netperf -H 198.18.40.2 -t TCP_RR  -l 60 -T 6,6 -Cc
>  MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 198.18.40.2 
>  ()  port 0 AF_INET : histogram : demo : first burst 0 : cpu bind
>  Local /Remote
>  Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
>  Send   Recv   Size    Size   Time    Rate     local  remote local   remote
>  bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr
>  
>  16384  87380  1       1      60.00   78077.55  3.74   2.69   3.830   8.265  
>  16384  87380 

Tell us more about the -T6,6

For example how many TX/RX queues you have on the NIC, and which cpus
service interrupts.
