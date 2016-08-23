From: David Miller <davem@davemloft.net>
Subject: Re: [REGRESSION] Select hang with zero sized UDP packets
Date: Tue, 23 Aug 2016 11:25:15 -0700 (PDT)
Message-ID: <20160823.112515.318902967155957764.davem@davemloft.net>
References: <08d225a8-e98f-c0c6-271d-acc2584347fc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, samanthakumar@google.com, willemb@google.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: labbott@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <08d225a8-e98f-c0c6-271d-acc2584347fc@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Laura Abbott <labbott@redhat.com>
Date: Tue, 23 Aug 2016 10:53:26 -0700

> Fedora received a report[1] of a unit test failing on Ruby when using
> the
> 4.7 kernel. This was a test to send a zero sized UDP packet. With the
> 4.7 kernel, the test now timing out on a select instead of completing.
> The reduced ruby test is
> 
>   def test_udp_recvfrom_nonblock
>     u1 = UDPSocket.new
>     u2 = UDPSocket.new
>     u1.bind("127.0.0.1", 0)
>     u2.send("", 0, u1.getsockname)
>     IO.select [u1]  # test gets stuck here
>   ensure
>     u1.close if u1
>     u2.close if u2
>   end

Well, if there is no data, should select really wake up?

I think it's valid not to.
