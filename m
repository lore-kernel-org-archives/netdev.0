From: "David S. Miller" <davem@redhat.com>
Subject: Re: oops in tcp_v4_rcv.
Date: Wed, 28 May 2003 18:40:54 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030528.184054.78710412.davem@redhat.com>
References: <3ED54DBC.4020203@colorfullife.com>
	<3ED55F4D.1070306@colorfullife.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, akpm@digeo.com, acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: manfred@colorfullife.com
In-Reply-To: <3ED55F4D.1070306@colorfullife.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Manfred Spraul <manfred@colorfullife.com>
   Date: Thu, 29 May 2003 03:15:57 +0200

   I think I understand now what causes the crash:
   The tcp_ehash assumes that the entries are of the type 'struct inet_sock'.
   But the actual entry is of the type tcp_tw_bucket. And 'sk->inet.daddr' 
   is not shared between both structures.

Thanks for figuring this out.  Indeed, I had suspected the
sock layout change Arnaldo did early in 2.5.x as the main
possible suspect.

I'll try to fix this.
