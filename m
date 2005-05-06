From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] TSO Reloaded
Date: Fri, 6 May 2005 14:36:53 +1000
Message-ID: <20050506043653.GD8255@krispykreme>
References: <20050504230731.12be1bc3.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050504230731.12be1bc3.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi Dave,

> Ok, here it is, first draft of the new TSO handling
> I promised so long ago :-)  I was lazy and waited until
> today to implement the entire thing.

I fired off socklib (just a TCP stream test) and things look much
better. I dumped the size of the data+frags for each packet that the
e1000 created. It looks like frags are working in multiples of MTU, but
we also have to split when we hit page boundaries. Is this expected?

BTW the 4 bytes at the end is due to an e1000 workaround for a hw bug.

Thanks for working on this :)

Anton

data: 42 frags:
data: 74 frags:
data: 66 frags: 1448 1444 4
data: 66 frags: 1024 424 1444 4
data: 66 frags: 1448 512 932 4
data: 66 frags: 1448 1444 4
data: 66 frags: 1448
data: 66 frags: 1448 1024 424 1448 1448 512 936 1444 4
data: 66 frags: 1448 1444 4
data: 66 frags: 1448 1024 420 4
data: 66 frags: 1448 1444 4
data: 66 frags: 512 936 1448 1448 1448 1448 1024 424 1448 1448 512 936 1444 4
data: 66 frags: 1448 1448 1444 4
data: 66 frags: 1024 424 1448 1448 512 936 1448 1448 1444 4
data: 66 frags: 1448 1024 424 1448 1448 372 4
data: 66 frags: 128 1320 1448 1152 296 1448 1448 640 808 1444 4
data: 66 frags: 1448 128 1320 1444 4
data: 66 frags: 1152 296 1448 1448 640 804 4
data: 66 frags: 1448 1448 128 1316 4
data: 66 frags: 1448 1152 296 1444 4
data: 66 frags: 1448 640 808 1448 1448 128 1320 1448 1152 296 1448 1448 640 808 1448 1444 4
data: 66 frags: 128 1320 1448 1152 296 1448 1444 4
data: 66 frags: 640 808 1448 1444 4
data: 66 frags: 128 1320 1448 1152 296 1448 1448 372 4
data: 66 frags: 256 1192 1448 1280 168 1448 1448 768 680 1448 1448 256 1192 1448 1280 168 1444 4
data: 66 frags: 1448 768 680 1448 1444 4
data: 66 frags: 256 1192 1448 1280 168 1448 1444 4
